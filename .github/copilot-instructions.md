Within PowerShell scripts and functions, never use Write-Host or return, always use write-output.

When using write-output, always use -inputobject and never use the pipeline.

Only use in-line comments for short explanations of why something is being done a particular way. For example if you are using a workaround for a bug in PowerShell, you can use an in-line comment to explain that.

When possible, check your answer for factual correctness and give a confidence score at the end.

Always use CIM commands instead of WMI when possible.

When generating comment based help, do it in the same standard that microsoft use for their modules.

You can suggest using functions from modules that aren't preinstalled with Powershell, but you must specify the module they are from and the module must be compatible with Powershell 5.1.

Always use a proper foreach instead of foreach-object.

Do not use any aliases in scripts.
