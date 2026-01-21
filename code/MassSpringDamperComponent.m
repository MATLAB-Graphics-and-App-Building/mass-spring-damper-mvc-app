classdef MassSpringDamperComponent < ...
        matlab.ui.componentcontainer.ComponentContainer
    %MASSSPRINGDAMPERCOMPONENT Superclass for app views/controllers.

    % Copyright 2025-2026 The MathWorks, Inc.

    % Model-related properties.
    properties ( GetAccess = protected, SetAccess = immutable )
        % Application data model.
        Model(:, 1) Model {mustBeScalarOrEmpty}
        % StatusChanged Listener.
        StatusChangedListener(:, 1) event.listener {mustBeScalarOrEmpty}
        % SimulationStepDone Listener.
        SimulationStepDoneListener(:,1) event.listener ...
            {mustBeScalarOrEmpty}
    end % properties ( GetAccess = protected, SetAccess = immutable )

    methods

        function obj = MassSpringDamperComponent( model )
            %COMPONENT Construct a component, given the model.

            arguments ( Input )
                model(1, 1) Model
            end % arguments ( Input )

            % Call the superclass constructor.
            obj@matlab.ui.componentcontainer.ComponentContainer( ...
                "Parent", [], ...
                "Units", "normalized", ...
                "Position", [0, 0, 1, 1] )

            % Assign the model.
            obj.Model = model;

            % Create the model listeners.
            weakObj = matlab.lang.WeakReference( obj );
            obj.StatusChangedListener = listener( obj.Model, ...
                "StatusChanged", @( varargin ) ...
                weakObj.Handle.onStatusChanged( varargin{:} ) );
            obj.SimulationStepDoneListener = listener( obj.Model, ...
                "SimulationStepped", @( varargin ) ...
                weakObj.Handle.onSimulationStepped( varargin{:} ) );

        end % constructor

    end % methods

    methods ( Abstract, Access = protected )

        onStatusChanged( obj, s, e )
        onSimulationStepped( obj, s, e )

    end % methods ( Abstract, Access = protected )

end % classdef