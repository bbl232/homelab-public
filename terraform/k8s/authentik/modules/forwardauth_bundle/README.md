## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_authentik"></a> [authentik](#requirement\_authentik) | 2024.10.2 |
| <a name="requirement_kubernetes"></a> [kubernetes](#requirement\_kubernetes) | 2.33.0 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_authentik"></a> [authentik](#provider\_authentik) | 2024.10.2 |
| <a name="provider_kubernetes"></a> [kubernetes](#provider\_kubernetes) | 2.33.0 |

## Modules

No modules.

## Resources

| Name | Type |
|------|------|
| [authentik_application.app](https://registry.terraform.io/providers/goauthentik/authentik/2024.10.2/docs/resources/application) | resource |
| [authentik_group.app_access](https://registry.terraform.io/providers/goauthentik/authentik/2024.10.2/docs/resources/group) | resource |
| [authentik_policy_binding.app-access](https://registry.terraform.io/providers/goauthentik/authentik/2024.10.2/docs/resources/policy_binding) | resource |
| [authentik_provider_proxy.app](https://registry.terraform.io/providers/goauthentik/authentik/2024.10.2/docs/resources/provider_proxy) | resource |
| [kubernetes_manifest.middleware_authentik](https://registry.terraform.io/providers/hashicorp/kubernetes/2.33.0/docs/resources/manifest) | resource |
| [authentik_flow.default_authorization_flow](https://registry.terraform.io/providers/goauthentik/authentik/2024.10.2/docs/data-sources/flow) | data source |
| [authentik_flow.default_invalidation_flow](https://registry.terraform.io/providers/goauthentik/authentik/2024.10.2/docs/data-sources/flow) | data source |
| [authentik_property_mapping_provider_scope.scope](https://registry.terraform.io/providers/goauthentik/authentik/2024.10.2/docs/data-sources/property_mapping_provider_scope) | data source |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_additional_auth_response_headers"></a> [additional\_auth\_response\_headers](#input\_additional\_auth\_response\_headers) | List of additional headers to forward on to the application you're proxying to. (Optional) | `list(string)` | `[]` | no |
| <a name="input_additional_property_mapping_ids"></a> [additional\_property\_mapping\_ids](#input\_additional\_property\_mapping\_ids) | List of additional property mapping IDs to assign to this provider. (Optional) | `list(string)` | `[]` | no |
| <a name="input_app_cookie_domain"></a> [app\_cookie\_domain](#input\_app\_cookie\_domain) | Domain that cookies will be set for. (Optional) | `string` | `"billv.ca"` | no |
| <a name="input_app_external_host"></a> [app\_external\_host](#input\_app\_external\_host) | External URL for the application. | `string` | n/a | yes |
| <a name="input_app_group"></a> [app\_group](#input\_app\_group) | Group to assign the application to. {Optional} | `string` | `"Home Services"` | no |
| <a name="input_app_icon"></a> [app\_icon](#input\_app\_icon) | URL to an icon to assign to the application. (Optional) | `string` | `""` | no |
| <a name="input_app_mode"></a> [app\_mode](#input\_app\_mode) | Proxy mode. (Optional) | `string` | `"forward_single"` | no |
| <a name="input_app_name"></a> [app\_name](#input\_app\_name) | Human friendly application name. | `string` | n/a | yes |
| <a name="input_app_namespace"></a> [app\_namespace](#input\_app\_namespace) | Namespace that the proxied application is running in. This is the namespace that the module will generate Traefik config in. | `string` | n/a | yes |
| <a name="input_app_slug"></a> [app\_slug](#input\_app\_slug) | Machine friendly application name. | `string` | n/a | yes |
| <a name="input_authorization_flow"></a> [authorization\_flow](#input\_authorization\_flow) | Name of the authorization flow to use for the provider. (Optional) | `string` | `"default-provider-authorization-implicit-consent"` | no |
| <a name="input_invalidation_flow"></a> [invalidation\_flow](#input\_invalidation\_flow) | Name of the invalidation flow to use for the provider. (Optional) | `string` | `"default-invalidation-flow"` | no |
| <a name="input_outpost_name"></a> [outpost\_name](#input\_outpost\_name) | Authentik outpost name to send forwardauth requests from Traefik to. | `string` | n/a | yes |
| <a name="input_refresh_token_validity"></a> [refresh\_token\_validity](#input\_refresh\_token\_validity) | How long tokens will be valid for. (Optional) | `string` | `"hours=1"` | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_access_group_id"></a> [access\_group\_id](#output\_access\_group\_id) | Authentik group that can be assigned to grant users access to this application. |
| <a name="output_provider_id"></a> [provider\_id](#output\_provider\_id) | Authentik provider ID that was created for this application. Must be added to an outpost for successful auth flow. |
