classdef MassSpringDamperComponent < ...
        matlab.ui.componentcontainer.ComponentContainer
    %MASSSPRINGDAMPERCOMPONENT Superclass for app views/controllers.

    % Copyright 2025-2026 The MathWorks, Inc.
    
    properties ( GetAccess = protected, SetAccess = immutable, Hidden )
        % Application data model.
        Model(:, 1) massSpringDamper.Model {mustBeScalarOrEmpty}
    end % properties ( GetAccess = protected, 
    % SetAccess = immutable, Hidden )

    properties ( Access = protected )
        % Simulink model bindings.
        Bindings(:, 1) matlab.lang.Binding
    end % properties ( Access = protected )

    methods

        function obj = MassSpringDamperComponent( model )
            %COMPONENT Construct a component, given the model.

            arguments ( Input )
                model(1, 1) massSpringDamper.Model
            end % arguments ( Input )

            % Call the superclass constructor.
            obj@matlab.ui.componentcontainer.ComponentContainer( ...
                "Parent", [], ...
                "Units", "normalized", ...
                "Position", [0, 0, 1, 1] )

            % Assign the model.
            obj.Model = model;

        end % constructor

        function delete( obj )
            %DELETE Release the bindings when the component is deleted.

            delete( obj.Bindings )
            
        end % delete

    end % methods

end % classdef