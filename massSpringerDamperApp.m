function varargout = massSpringerDamperApp()
%MASSSPRINGERDAMPERAPP Launch the mass-spring-damper simulation app.

% Check the number of outputs.
nargoutchk( 0, 1 )

% Launch the application.
L = MassSpringDamperLauncher;

% Return the figure if requested.
if nargout == 1
    varargout{1} = L.Figure;
end % if

end % massSpringDamperApp