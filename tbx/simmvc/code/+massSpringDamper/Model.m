classdef Model < handle
    %MODEL Data model for the mass-spring-damper app.

    % Copyright 2025-2026 The MathWorks, Inc

    properties ( SetObservable )
        % Spring stiffness - k (N/m).
        Stiffness(1, 1) double {mustBePositive, mustBeFinite} = 100
        % Mass - m (kg).
        Mass(1, 1) double {mustBePositive, mustBeFinite} = 10
        % Damping coefficient - b (N/m/s).
        DampingCoefficient(1, 1) double {mustBePositive, mustBeFinite} = 1
        % Initial position/displacement - x0 (m).
        InitialPosition(1, 1) double ...
            {mustBeNonnegative, mustBeFinite} = 0.5        
    end % properties ( SetObservable )

    properties ( Constant )
        % Simulink model name.
        SimulinkModelName(1, 1) string = "MassSpringDamperModel"
        % Model image file.
        ImageFile(1, 1) string {mustBeFile} = fullfile( simmvcroot(), ...
            "models", ...
            massSpringDamper.Model.SimulinkModelName + ".svg" )
        % Signal names.
        SignalNames(1, 4) string = ["Force", "Position", ...
            "Velocity", "Acceleration"]
        % Signal units.
        SignalUnits(1, 4) string = ["N", "m", "m/s", "m/s^2"]
        % Signal paths.
        LoggedSignalPath(1, 4) string = ...
            massSpringDamper.Model.SimulinkModelName + ...
            ["/External Force:1", "/Second-Order Integrator:1", ...
            "/Second-Order Integrator:2", "/Mass:1"]        
        % Number of signals.
        NumSignals(1, 1) double {mustBeInteger, mustBePositive} = ...
            numel( massSpringDamper.Model.SignalNames )
    end % properties ( Constant )

    properties ( SetAccess = private )
        % Simulation object, of type simulink.Simulation.
        Simulation(:, 1) simulink.Simulation {mustBeScalarOrEmpty} = ...
            simulink.Simulation.empty( 0, 1 )
    end % properties ( SetAccess = private )

    methods

        function obj = Model( namedArgs )
            %MODEL Construct the model.

            arguments ( Input )
                namedArgs.?massSpringDamper.Model
            end % arguments ( Input )

            % Load the model and create the Simulation object.
            obj.Simulation = simulink.Simulation( ...
                obj.SimulinkModelName );

            % Assign any user-specified properties.
            names = string( fieldnames( namedArgs ) ).';
            for name = names
                obj.(name) = namedArgs.(name);
            end % for

            % Update the tunable variables with the current values from
            % the model.
            obj.modifyParameter( "k", obj.Stiffness )
            obj.modifyParameter( "m", obj.Mass )
            obj.modifyParameter( "b", obj.DampingCoefficient )
            obj.modifyParameter( "x0", obj.InitialPosition )           

            % Allow the model to run indefinitely and adjust the simulation
            % pacing.
            setModelParameter( obj.Simulation, "StopTime", "Inf", ...
                "EnablePacing", "on", ...
                "PacingRate", "3" )

        end % constructor

        function delete( obj )
            %DELETE Delete the Simulation object.

            delete( obj.Simulation )

        end % delete

        function startSimulation( obj )
            %STARTSIMULATION Start the Simulink simulation.
            
            start( obj.Simulation )

        end % startSimulation

        function varargout = stopSimulation( obj )
            %STOPSIMULATION Stop the Simulink simulation.

            nargoutchk( 0, 1 )
            simOut = stop( obj.Simulation );            
            if nargout == 1
                varargout{1} = simOut;
            end % if

        end % stopSimulation

        function t = tabulateVariables( obj )
            %TABULATEVARIABLES Return a table of Simulink model variables
            %maintained by the Simulation object.

            t = table( obj.Simulation.Variables );

        end % tabulateVariables

        function set.Stiffness( obj, value )

            obj.Stiffness = value;
            obj.modifyParameter( "k", obj.Stiffness )

        end % set.Stiffness

        function set.Mass( obj, value )

            obj.Mass = value;
            obj.modifyParameter( "m", obj.Mass )

        end % set.Mass       

        function set.DampingCoefficient( obj, value )

            obj.DampingCoefficient = value;
            obj.modifyParameter( "b", obj.DampingCoefficient )

        end % set.DampingCoefficient

        function set.InitialPosition( obj, value )

            obj.InitialPosition = value;
            obj.modifyParameter( "x0", obj.InitialPosition )

        end % set.InitialPosition        

    end % methods

    methods ( Access = private )

        function modifyParameter( obj, paramName, paramValue )
            %MODIFYPARAMETER Modify the given Simulink simulation
            %parameter.

            % Update the simulation object.
            setVariable( obj.Simulation, paramName, paramValue )

        end % modifyParameter

    end % methods ( Access = private )

end % classdef