Within PowerShell scripts and functions, never use Write-Host or return, always use write-output.

When using write-output, always use -inputobject and never use the pipeline. You do not need to explicitly declare -inputobject as a parameter and can instead use it as positional, e.g. Write-Output $object

Only use in-line comments for short explanations of why something is being done a particular way. For example if you are using a workaround for a bug in PowerShell, you can use an in-line comment to explain that.

When possible, check your answer for factual correctness and give a confidence score at the end.

Always use CIM commands instead of WMI when possible.

When generating comment based help, do it in the same standard that microsoft use for their modules.

You can suggest using functions from modules that aren't preinstalled with Powershell, but you must specify the module they are from and the module must be compatible with Powershell 5.1.

Always use a proper foreach instead of foreach-object.

Do not use any aliases in scripts.

When responding to questions on how to make a change to a script, only include the relevant part of the script that needs to be changed, not the entire script. If the change is large, provide a summary of the changes and then provide the full updated script.

When creating variables, always use Pascalcase for the variable name. For example, $MyVariable instead of $myvariable or $myVariable. Variable names should also be descriptive and meaningful. For example, $UserName instead of $u or $name.

When creating parameters, always use Pascalcase for the parameter name. For example, MyParameter instead of myparameter or myParameter.

Never place certificates or secrets inside a repository. This includes hard coding them into scripts.
