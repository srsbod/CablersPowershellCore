Within PowerShell scripts and functions, never use Write-Host or return, always use write-output.

When using write-output, always use -inputobject and never use the pipeline. You do not need to explicitly declare -inputobject as a parameter and can instead use it as positional, e.g. Write-Output $object

Only use in-line comments for short explanations of why something is being done a particular way. For example if you are using a workaround for a bug in PowerShell, you can use an in-line comment to explain that.

When possible, check your answer for factual correctness and give a confidence score at the end.

Always use CIM commands instead of WMI when possible.

When generating comment based help, do it in the same standard that microsoft use for their modules.

You can suggest using functions from modules that aren't preinstalled with Powershell, but you must specify the module they are from and the module must be compatible with Powershell 5.1.

Always use a proper foreach instead of foreach-object.

Do not use any aliases in scripts.

When making edits to a function such as adding or removing parameters, always make appropriate changes to the tests file as well.

When responding to questions on how to make a change to a script, only include the relevant part of the script that needs to be changed, not the entire script. If the change is large, provide a summary of the changes and then provide the full updated script.

When creating variables, always use Pascalcase for the variable name. For example, $MyVariable instead of $myvariable or $myVariable. Variable names should also be descriptive and meaningful. For example, $UserName instead of $u or $name.

When creating parameters, always use Pascalcase for the parameter name. For example, MyParameter instead of myparameter or myParameter.

Never place certificates or secrets inside a repository. This includes hard coding them into scripts.

When generating commit messages or pull request titles, always use the present tense and start with a verb. For example, "Add new feature" instead of "Added new feature" or "Adding new feature". The commit message should be descriptive and meaningful, explaining what the commit does and why it was made. For example, "Fix bug in script that caused it to fail on Windows 10" instead of "Fix bug". The commit message should also be concise and to the point, avoiding unnecessary words or phrases. For example, "Update README.md" instead of "Updated the README file to include more information about the project".

When generating pull request descriptions, go into more detail about the changes made in the pull request. Include information about what was changed, why it was changed, and any relevant context or background information. The description should also include any relevant links to issues or discussions related to the changes made in the pull request. For example, "This pull request fixes issue #123 by updating the script to handle errors more gracefully. The changes were made to improve the user experience and prevent crashes on Windows 10." The description should also include any relevant information about testing or validation that was done to ensure the changes work as expected.

When generating test cases, always use the Pester framework and follow the Pester best practices. This includes using descriptive names for test cases, using the Arrange-Act-Assert pattern, and including comments to explain the purpose of each test case. For example, "Describe 'MyFunction' { It 'should return the expected result' { $Result = MyFunction -InputObject $InputObject $Result | Should -BeExactly $ExpectedResult } }". The test cases should also include positive and negative test cases to ensure that the function works as expected in all scenarios.

When generating releases, always use semantic versioning. This includes using a version number in the format of MAJOR.MINOR.PATCH, where MAJOR is incremented for breaking changes, MINOR is incremented for new features, and PATCH is incremented for bug fixes. For example, "1.0.0" for the first release, "1.1.0" for a new feature, and "1.0.1" for a bug fix. The release notes should also include a summary of the changes made in the release, including any new features, bug fixes, or breaking changes. The release notes should also include any relevant links to issues or discussions related to the changes made in the release. For example, "This release includes a new feature that allows users to export data to CSV format. This feature was requested in issue #123 and has been implemented based on user feedback." The release notes should also include any relevant information about testing or validation that was done to ensure the changes work as expected.

When generating documentation, always use markdown format and follow the markdown best practices. This includes using headings, lists, and code blocks to organize the content and make it easy to read. For example, "# My Function" for the function name, "## Parameters" for the parameters section, and "```powershell" for code blocks. The documentation should also include examples of how to use the function, including input and output examples. For example, "## Example 1: Get User Information" with a code block showing the command and expected output. The documentation should also include any relevant links to issues or discussions related to the function. For example, "This function was implemented based on user feedback from issue #123." The documentation should also include any relevant information about testing or validation that was done to ensure the function works as expected.
