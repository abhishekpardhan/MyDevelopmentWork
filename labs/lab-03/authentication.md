# Authentication - administrator setup requires approval

Follow the current [Agent API ECA setup](https://developer.salesforce.com/docs/ai/agentforce/guide/agent-api-get-started.html). No app or OAuth policy was created or changed in this lab.

In Setup > External Client Apps Manager > New External Client App, provide a lab name/contact and enable OAuth. The documented scopes are `api`, `refresh_token/offline_access`, `chatbot_api`, and `sfap_api`. Enable client credentials and JWT-based access tokens for named users. Review the guide's additional OAuth settings with your administrator; do not alter unrelated apps.

In the app's Policies tab, enable client credentials and choose Run As. The guide specifies a user with at least API Only access; verify API Enabled, assigned agent access, and required action/data permissions separately. Scopes grant API access, not record access. Use an appropriately licensed, least-privilege identity.

The token is obtained by POSTing an URL-encoded `grant_type=client_credentials`, `client_id`, and `client_secret` to `https://<MyDomain>/services/oauth2/token`. Use `access_token` as `Authorization: Bearer <token>` on Agent API requests. The client keeps it in memory and never prints the OAuth response.

Execution identity:

| Setting | Identity |
|---|---|
| `bypassUser=false` | Token's user; with client credentials, the ECA Run As user |
| `bypassUser=true` | Agent-assigned user, per Agent API documentation |

The guide's service-oriented example uses true, but explicitly allows choosing the value for the use case. Lab 03 requires false for the existing Employee Agent as a deliberate lab policy. This is not an authorization bypass. Changing it requires review; it does not assign permissions or create a user.

Token expiry follows the app's JWT/session policy; do not hard-code an assumed lifetime. Client credentials obtains a fresh access token, not a reusable refresh token workflow. On 401 the client stops, does not replay a message, and attempts cleanup. After checking expiry/policy, acquire a new token for an explicitly chosen next attempt. Cleanup can also fail if the token is expired.

Use process environment variables described in `.env.example`. Enter the key and secret through the masked prompts in README.md, not literal command arguments. Do not persist them in shell history, transcripts, screenshots, files, or Git. Environment variables and in-memory objects are not a vault; clear credentials after use and use an enterprise secret store for production. `.env`, secret directories, private keys, logs, output, and virtual environments are ignored locally. No real credentials were supplied or read.
