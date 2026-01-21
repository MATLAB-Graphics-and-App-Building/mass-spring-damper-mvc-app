classdef SignalView < MassSpringDamperComponent
    %SIGNALVIEW Displays the simulation signals for the External Force,
    %Acceleration, Velocity and Position.

    properties ( Access = private )
        % Timescope to display the external force.
        ExternalForceScope(:, 1) matlab.ui.scope.TimeScope ...
            {mustBeScalarOrEmpty}
        % Timescope to display the acceleration.
        AccelerationScope(:, 1) matlab.ui.scope.TimeScope ...
            {mustBeScalarOrEmpty}
        % Timescope to display the velocity.
        VelocityScope(:, 1) matlab.ui.scope.TimeScope {mustBeScalarOrEmpty}
        % Timescope to display the position.
        PositionScope(:, 1) matlab.ui.scope.TimeScope {mustBeScalarOrEmpty}
    end % properties ( Access = private )

    methods

        function obj = SignalView( model, namedArgs )
            %SIGNALVIEW Construct a SignalView object, given
            %the model and optional name-value pairs.

            arguments ( Input )
                model(1, 1) Model
                namedArgs.?SignalView
            end % arguments ( Input )

            % Call the superclass constructor.
            obj@MassSpringDamperComponent( model )

            % Set any user-specified properties.
            set( obj, namedArgs )

        end % constructor

    end % methods

    methods ( Access = protected )

        function onStatusChanged( ~, ~, ~ )
            %ONSTATUSCHANGED Respond to the model event "StatusChanged".

        end % onStatusChanged

        function onSimulationStepped( obj, ~, ~ )
            %ONSIMULATIONSTEPPED Respond to the model event
            %"SimulationStepped".

            obj.Model

        end % onSimulationStepped

        function setup( obj )
            %SETUP Initialize the component.

            % Create the main layout.
            mainLayout = uigridlayout( obj, [4, 1], "Padding", 0 );

            % Create the time scopes.
            obj.ExternalForceScope = uitimescope( ...
                "Parent", mainLayout, ...
                "XTimeSpan", 1, ...
                "YLimits", [0, 1], ...
                "Title", "External Force" );            
            obj.AccelerationScope = uitimescope( ...
                "Parent", mainLayout, ...
                "XTimeSpan", 1, ...
                "YLimits", [0, 1], ...
                "Title", "Acceleration" );
            obj.VelocityScope = uitimescope( ...
                "Parent", mainLayout, ...
                "XTimeSpan", 1, ...
                "YLimits", [0, 1], ...
                "Title", "Velocity" );            
            obj.PositionScope = uitimescope( ...
                "Parent", mainLayout, ...
                "XTimeSpan", 1, ...
                "YLimits", [0, 1], ...
                "Title", "Position" );           

        end % setup

        function update( ~ )
            %UPDATE Update the component's graphics.

        end % update

    end % methods ( Access = protected )

end % classdef