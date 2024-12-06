Within PowerShell scripts, never use Write-Host, always use Write-Output instead.

In-line comments in code are fine but omit the usual summary at the end.

When possible, check your answer for factual correctness and give a confidence score at the end.

Always use CIM instead of WMI when possible.

When generating comment based help, do it in the same standard that microsoft use for their modules.

You can suggest using functions from modules that aren't preinstalled with Powershell, but you must specify the module they are from and the module must be compatible with Powershell 5.1.

Always use a proper foreach instead of foreach-object.
