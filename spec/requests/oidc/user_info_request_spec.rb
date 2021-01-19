RSpec.describe "/oidc/user_info" do
  let(:token) { "123456" }

  let(:headers) { { accept: "application/json", authorization: "Bearer #{token}" } }

  let(:token_scopes) { %w[test_scope_1 test_scope_2] }

  let(:token_hash) do
    {
      true_subject_identifier: "true-subject-identifier",
      pairwise_subject_identifier: "pairwise-subject-identifier",
      scopes: token_scopes,
    }
  end

  describe "GET" do
    context "with a valid token" do
      before { stub_token_response token_hash }

      it "returns 200" do
        get "/oidc/user_info", headers: headers
        expect(response).to be_successful
      end

      it "includes the pairwise subject identifier" do
        get "/oidc/user_info", headers: headers
        expect(JSON.parse(response.body)).to include("sub" => token_hash[:pairwise_subject_identifier])
      end

      it "does not include the true subject identifier" do
        get "/oidc/user_info", headers: headers
        expect(response.body).to_not include(token_hash[:true_subject_identifier])
      end

      context "a claim exists" do
        let!(:claim) do
          FactoryBot.create(
            :claim,
            subject_identifier: token_hash[:true_subject_identifier],
            claim_identifier: Permissions::TEST_CLAIM_IDENTIFIER,
            claim_value: "hello world",
          )
        end

        it "doesn't include the claim in the response" do
          get "/oidc/user_info", headers: headers
          expect(response.body).to_not include(claim.claim_identifier)
        end

        context "the token has access to the claim" do
          let(:token_scopes) { [Permissions::TEST_READ_SCOPE] }

          it "includes the claim in the response" do
            get "/oidc/user_info", headers: headers
            expect(JSON.parse(response.body)).to include(claim.claim_name.to_s => claim.claim_value)
          end
        end
      end
    end

    context "with an invalid token" do
      before { stub_token_response nil, status: 404 }

      it "returns 401" do
        get "/oidc/user_info", headers: headers
        expect(response).to have_http_status(:unauthorized)
      end
    end

    context "with an expired token" do
      before { stub_token_response nil, status: 410 }

      it "returns 401" do
        get "/oidc/user_info", headers: headers
        expect(response).to have_http_status(:unauthorized)
      end
    end

    context "with the account manager down" do
      before { stub_token_response nil, status: 500 }

      it "returns 500" do
        get "/oidc/user_info", headers: headers
        expect(response).to have_http_status(:internal_server_error)
      end
    end
  end
end
