# PowerBI: Using PowerShell Cmdlets to retrieve Metadata

This script is an example how to retrieve metadata of reports and datasets from all workspaces in PowerBI using [PowerBI Cmdlets](https://learn.microsoft.com/en-us/powershell/power-bi/overview?view=powerbi-ps).

# Prerequisites

- PowerShell Core v7.3+
- [Azure AD service principal](#create-azure-ad-service-principal)
- [Configured permissions in PowerBI](#configure-permissions-in-powerbi)

# Create Azure AD service principal

Follow these steps to create service principal in Azure AD:

1. Sign-in to the [Azure portal](https://portal.azure.com/).
2. Search for and Select `Azure Active Directory`.
3. Select `App registrations`, then select `New registration`.
4. Name the application, for example `example-app`.
5. Select a supported account type, which determines who can use the application. Value `Accounts in this organizational directory only - Single tenant` will be suitable for most cases.
6. Select `Register`.

You've created your Azure AD application and service principal. Note down the application (client) id (will be used later).

Now create client secret:

1. Select `Certificates & secrets`, then select `Client secrets` and `New client secret`
2. Enter secret description, for example `powershell-secret` and select `Add`.
3. Note down the `Value` of newly created secret (it will be not visible anymore after you leave this screen).

Consider using certificates instead of client secrets for higher security. PowerBI PowerShell script can be adapted to accept certificate instead of client secret.

> **Warning**
>
> An app using service principal authentication that calls PowerBI read-only admin APIs must not have any admin-consent required permissions for Power BI set on it in the Azure portal. Therefore do not add any API permissions in Azure AD, permissions for service principals are configured in PowerBI.

Now create security group for service principals that will be used to grant access to PowerBI:

1. Search for and Select `Azure Active Directory`.
2. Select `Groups`, then select `New group`.
3. Enter group name, for example `PowerBI Service Principals`.
4. Under `Members` select `No members selected` to add service principals to this group.
5. Search for service principal created in previous steps and select it.
6. Select `Select` and then `Create`.

Using security group in PowerBI will grant access to PowerBI API only to service principals in this security group (not all service principals defined in organization).

# Configure permissions in PowerBI

1. Sign-in to [PowerBI Admin Portal](https://app.powerbi.com/admin-portal/tenantSettings?experience=power-bi).
2. Select `Tenant settings`.
3. Search for `Allow service principals to use Power BI APIs` and enable it for security group created in chapter [Create Azure service principal](#create-azure-ad-service-principal). This setting allows service principal in specified security group to access PowerBI API.
4. Search for `Allow service principals to use read-only admin APIs` and enable it for security group created in chapter [Create Azure service principal](#create-azure-ad-service-principal). This setting allows service principal in specified security group to access PowerBI admin API.

# Running the script

Run the script in PowerShell with following command:

```bash
get_reports.ps1 -tenant <TENANT> -applicationId <APP_ID> -secret <PASSWORD>
```

Following are the parameters expected by PowerShell script:

| Parameter     | Value                                       |
| ------------- | ------------------------------------------- |
| tenant        | Your tenant, e.g. `contoso.onmicrosoft.com` |
| applicationId | Application Id of service principal         |
| secret        | Service principal's client secret                  |

Output from script is JSON with reports and datasets:

```json
{
  "Datasets": [
    {
      "Id": "647d60ed-8040-45aa-b36e-dc64aa7538a3",
      "Name": "Table",
      "DefaultRetentionPolicy": null,
      "AddRowsApiEnabled": false,
      "Tables": null,
      "WebUrl": null,
      "Relationships": null,
      "Datasources": null,
      "DefaultMode": null,
      "IsRefreshable": true,
      "IsEffectiveIdentityRequired": false,
      "IsEffectiveIdentityRolesRequired": false,
      "IsOnPremGatewayRequired": false,
      "TargetStorageMode": "Abf",
      "ActualStorage": null,
      "CreatedDate": "2023-06-07T16:48:25.99Z",
      "ContentProviderType": "InImportMode",
      "Workspace": {
        "Id": "7715e983-63f9-4953-83e8-d303160d377b",
        "Name": "Workspace 1"
      }
    }
  ],
  "Reports": [
    {
      "Id": "224de5a6-c14c-4d4f-a564-295f8b8f510a",
      "Name": "TestReport",
      "WebUrl": null,
      "EmbedUrl": null,
      "DatasetId": "647d60ed-8040-45aa-b36e-dc64aa7538a3",
      "Workspace": {
        "Id": "25e4d443-c36b-49fb-a845-8347ee5dffb0",
        "Name": "TestWorkspace"
      }
    }
  ]
}
```

# Resources

- [Create an Azure Active Directory application and service principal that can access resources](https://learn.microsoft.com/en-us/azure/active-directory/develop/howto-create-service-principal-portal)
- [Automate Premium workspace and dataset tasks with service principals](https://learn.microsoft.com/en-us/power-bi/enterprise/service-premium-service-principal)
- [Embed Power BI content with service principal and an application secret](https://learn.microsoft.com/en-us/power-bi/developer/embedded/embed-service-principal#step-3---enable-the-power-bi-service-admin-settings)
- [Enable service principal authentication for read-only admin APIs](https://learn.microsoft.com/en-us/power-bi/enterprise/read-only-apis-service-principal-authentication)
- [Microsoft Power BI Cmdlets](https://learn.microsoft.com/en-us/powershell/power-bi/overview?view=powerbi-ps)
- [Using the Power BI REST APIs](https://learn.microsoft.com/en-us/rest/api/power-bi/)

# License

Distributed under MIT License. See [LICENSE](LICENSE) for more details.
