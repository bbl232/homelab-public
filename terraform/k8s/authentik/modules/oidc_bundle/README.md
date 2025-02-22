## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_authentik"></a> [authentik](#requirement\_authentik) | 2024.10.2 |
| <a name="requirement_random"></a> [random](#requirement\_random) | 3.6.3 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_authentik"></a> [authentik](#provider\_authentik) | 2024.10.2 |
| <a name="provider_random"></a> [random](#provider\_random) | 3.6.3 |

## Modules

No modules.

## Resources

| Name | Type |
|------|------|
| [authentik_application.app](https://registry.terraform.io/providers/goauthentik/authentik/2024.10.2/docs/resources/application) | resource |
| [authentik_group.app_admins](https://registry.terraform.io/providers/goauthentik/authentik/2024.10.2/docs/resources/group) | resource |
| [authentik_group.app_users](https://registry.terraform.io/providers/goauthentik/authentik/2024.10.2/docs/resources/group) | resource |
| [authentik_policy_binding.admin-app-access](https://registry.terraform.io/providers/goauthentik/authentik/2024.10.2/docs/resources/policy_binding) | resource |
| [authentik_policy_binding.app-access](https://registry.terraform.io/providers/goauthentik/authentik/2024.10.2/docs/resources/policy_binding) | resource |
| [authentik_provider_oauth2.app](https://registry.terraform.io/providers/goauthentik/authentik/2024.10.2/docs/resources/provider_oauth2) | resource |
| [random_password.client_id](https://registry.terraform.io/providers/hashicorp/random/3.6.3/docs/resources/password) | resource |
| [random_password.client_secret](https://registry.terraform.io/providers/hashicorp/random/3.6.3/docs/resources/password) | resource |
| [authentik_flow.default_authorization_flow](https://registry.terraform.io/providers/goauthentik/authentik/2024.10.2/docs/data-sources/flow) | data source |
| [authentik_flow.default_invalidation_flow](https://registry.terraform.io/providers/goauthentik/authentik/2024.10.2/docs/data-sources/flow) | data source |
| [authentik_property_mapping_provider_scope.scope](https://registry.terraform.io/providers/goauthentik/authentik/2024.10.2/docs/data-sources/property_mapping_provider_scope) | data source |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_allowed_redirect_uris"></a> [allowed\_redirect\_uris](#input\_allowed\_redirect\_uris) | Configuration for allowed application redirect URLs. (Optional) | `list(object({matching_mode = string, url = string}))` | <pre>[<br/>  {<br/>    "matching_mode": "regex",<br/>    "url": "https://.*.billv.ca/.*"<br/>  }<br/>]</pre> | no |
| <a name="input_app_group"></a> [app\_group](#input\_app\_group) | Group to assign the application to. {Optional} | `string` | `"Home Services"` | no |
| <a name="input_app_icon"></a> [app\_icon](#input\_app\_icon) | URL to an icon to assign to the application. (Optional) | `string` | `""` | no |
| <a name="input_app_launch_url"></a> [app\_launch\_url](#input\_app\_launch\_url) | URL used to launch the applicatoin from the User Dashboard. | `string` | n/a | yes |
| <a name="input_app_name"></a> [app\_name](#input\_app\_name) | Human friendly application name. | `string` | n/a | yes |
| <a name="input_app_slug"></a> [app\_slug](#input\_app\_slug) | Machine friendly application name. | `string` | n/a | yes |
| <a name="input_authorization_flow"></a> [authorization\_flow](#input\_authorization\_flow) | Name of the authorization flow to use for the provider. (Optional) | `string` | `"default-provider-authorization-implicit-consent"` | no |
| <a name="input_client_id"></a> [client\_id](#input\_client\_id) | Client ID to use for this provider. (Optional) | `string` | `""` | no |
| <a name="input_client_secret"></a> [client\_secret](#input\_client\_secret) | Client Secret to use for this provider. (Optional) | `string` | `""` | no |
| <a name="input_client_type"></a> [client\_type](#input\_client\_type) | Provider client type. Should be either "confidential" or "public". (Optional) | `string` | `"confidential"` | no |
| <a name="input_invalidation_flow"></a> [invalidation\_flow](#input\_invalidation\_flow) | Name of the invalidation flow to use for the provider. (Optional) | `string` | `"default-invalidation-flow"` | no |
| <a name="input_oauth_scopes"></a> [oauth\_scopes](#input\_oauth\_scopes) | Oauth scopes to assign to the provider. (Optional) | `list(string)` | <pre>[<br/>  "goauthentik.io/providers/oauth2/scope-email",<br/>  "goauthentik.io/providers/oauth2/scope-openid",<br/>  "goauthentik.io/providers/oauth2/scope-profile"<br/>]</pre> | no |
| <a name="input_signing_key"></a> [signing\_key](#input\_signing\_key) | Signing key to use for the provider. Should be the ID of the signing key in Authentik. | `string` | n/a | yes |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_admins_group_id"></a> [admins\_group\_id](#output\_admins\_group\_id) | Authentik group that can be assigned to administrators of this application. |
| <a name="output_client_id"></a> [client\_id](#output\_client\_id) | Client ID configured for the provider. |
| <a name="output_client_secret"></a> [client\_secret](#output\_client\_secret) | Client Secret configured for the provider. |
| <a name="output_users_group_id"></a> [users\_group\_id](#output\_users\_group\_id) | Authentik group that can be assigned to users of this application. |
