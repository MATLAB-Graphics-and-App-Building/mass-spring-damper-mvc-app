function plan = buildfile()
%BUILDFILE Mass Spring Damper MVC App build file.

% Copyright 2025-2026 The MathWorks, Inc.

% Define the build plan.
plan = buildplan( localfunctions() );

% Set the archive task to run by default.
plan.DefaultTasks = "archive";

% The archive task depends on the check task.
plan("archive").Dependencies = "check";

end % buildfile

function checkTask( context )
% Check the source code and project for any issues.

% Set the project root as the folder in which to check for any static code
% issues.
projectRoot = context.Plan.RootFolder;
codeIssuesTask = matlab.buildtool.tasks.CodeIssuesTask( projectRoot, ...
    "IncludeSubfolders", true, ...
    "Configuration", "factory", ...
    "Description", ...
    "Assert that there are no code issues in the project.", ...
    "WarningThreshold", 0 );
codeIssuesTask.analyze( context )

% Update the project dependencies.
prj = currentProject();
prj.updateDependencies()

% Run the checks.
checkResults = table( prj.runChecks() );

% Log any failed checks.
passed = checkResults.Passed;
notPassed = ~passed;
if any( notPassed )
    disp( checkResults(notPassed, :) )
else
    fprintf( "** All project checks passed.\n\n" )
end % if

% Check that all checks have passed.
assert( all( passed ), "buildfile:ProjectIssue", ...
    "At least one project check has failed. " + ...
    "Resolve the failures shown above to continue." )

end % checkTask

function archiveTask( ~ )
% Archive the project.

proj = currentProject();
projectRoot = proj.RootFolder;
exportName = fullfile( projectRoot, "MassSpringDamperMVCApp.mlproj" );
proj.export( exportName )

end % archiveTask

function compileTask( c )
% Compile the web application.

projectRoot = c.Plan.RootFolder;
appFile = fullfile( projectRoot, "MassSpringDamperApp.mlapp" );
simModel = fullfile( projectRoot, "MassSpringDamperModel.slx" );
opts = compiler.build.WebAppArchiveOptions( appFile );
opts.AdditionalFiles = simModel;
compiler.build.webAppArchive( opts );

end % compileTask