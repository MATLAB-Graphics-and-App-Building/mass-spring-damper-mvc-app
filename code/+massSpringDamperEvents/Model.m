classdef Model < handle
    %MODEL Data model for the mass-spring-damper app.

    % Copyright 2025-2026 The MathWorks, Inc

    properties
        % Spring stiffness (N/m).
        Stiffness(1, 1) double {mustBePositive, mustBeFinite} = 100
        % Mass (kg).
        Mass(1, 1) double {mustBePositive, mustBeFinite} = 10
        % Damping coefficient (N/m/s).
        DampingCoefficient(1, 1) double {mustBePositive, mustBeFinite} = 1
        % Initial position/displacement (m).
        InitialPosition(1, 1) double {mustBeNonnegative, mustBeFinite} = 0
        % Maximum force magnitude value (N).
        MaximumMagnitude(1, 1) double ...
            {mustBeNonnegative, mustBeFinite} = 100
        % Input change interval (s).
        InputChangeInterval(1, 1) double ...
            {mustBeNonnegative, mustBeFinite} = 5
    end % properties

    properties ( Constant )
        % Simulink model name.
        SimulinkModelName(1, 1) string = "MassSpringDamperModelEvents"
        % Model image file.
        ImageFile(1, 1) string {mustBeFile} = "models/" + ...
            massSpringDamperEvents.Model.SimulinkModelName + ".svg"
        % Signal names.
        SignalNames(1, 4) string = ["Force", "Position", ...
            "Velocity", "Acceleration"]
        % Signal units.
        SignalUnits(1, 4) string = ["N", "m", "m/s", "m/s^2"]
    end % properties ( Constant )

    properties ( SetAccess = private )
        % Simulation input object.
        SimulationInput(1, 1) Simulink.SimulationInput
        % Simulation output object.
        SimulationOutput(1, 1) Simulink.SimulationOutput
        % Simulation time.
        SimulationTime(1, 1) double {mustBeNonnegative, mustBeFinite} = 0
        % Output data.
        OutputLog(:, 4) timetable
        % Simulation status.
        SimulationStatus(1, 1) slsim.SimulationStatus = "Inactive"
    end % properties ( SetAccess = private )

    events ( NotifyAccess = private)
        % The simulation status has changed.
        StatusChanged
        % The simulation step has completed.
        SimulationStepped
    end % events ( NotifyAccess = private )

    methods

        function obj = Model( namedArgs )
            %MODEL Construct the model.

            arguments ( Input )
                namedArgs.?massSpringDamperEvents.Model
            end % arguments ( Input )

            load_system( obj.SimulinkModelName )

            names = string( fieldnames( namedArgs ) ).';
            for name = names
                obj.(name) = namedArgs.(name);
            end % for

        end % constructor

        function delete( obj )
            %DELETE Close the Simulink model.

            close_system( obj.SimulinkModelName, 0 )

        end % delete

        function startSimulation( obj )
            %STARTSIMULATION Start the Simulink simulation.
            
            simStatus = simulink.compiler.getSimulationStatus( ...
                obj.SimulinkModelName );

            if simStatus == slsim.SimulationStatus.Inactive
                obj.SimulationTime = 0;
                obj.SimulationInput = obj.initializeSimulationInput();
                obj.SimulationOutput = sim( obj.SimulationInput );
            end % if

        end % startSimulation

        function stopSimulation( obj )
            %STOPSIMULATION Stop the Simulink simulation.

            simStatus = simulink.compiler.getSimulationStatus( ...
                obj.SimulinkModelName );
            if simStatus == slsim.SimulationStatus.Running
                simulink.compiler.stopSimulation( obj.SimulinkModelName )
            end % if

        end % stopSimulation       

        function set.Stiffness( obj, value )

            obj.Stiffness = value;
            obj.modifyParameterDuringSimulation( "k", obj.Stiffness )

        end % set.Stiffness

        function set.Mass( obj, value )

            obj.Mass = value;
            obj.modifyParameterDuringSimulation( "m", obj.Mass )

        end % set.Mass

        function set.DampingCoefficient( obj, value )

            obj.DampingCoefficient = value;
            obj.modifyParameterDuringSimulation( ...
                "b", obj.DampingCoefficient )

        end % set.DampingCoefficient

        function set.InitialPosition( obj, value )

            obj.InitialPosition = value;
            obj.modifyParameterDuringSimulation( ...
                "x0", obj.InitialPosition )

        end % set.InitialPosition

        function set.MaximumMagnitude( obj, value )

            obj.MaximumMagnitude = value;

        end % set.MaximumMagnitude

        function set.InputChangeInterval( obj, value )

            obj.InputChangeInterval = value;

        end % set.InputChangeInterval

    end % methods

    methods ( Access = private )

        function simInput = initializeSimulationInput( obj )
            %INITIALIZESIMULATIONINPUT Initialize the simulation input
            %object used by the Simulink model.

            % Create an empty simulation input object.
            simInput = Simulink.SimulationInput( obj.SimulinkModelName );

            % Set the status changed function.
            simInput = simulink.compiler.setSimulationStatusChangeFcn( ...
                simInput, @( simStatus ) ...
                obj.onSimulationStatusChanged( simStatus ) );

            % Specify the external inputs function.
            simInput = simulink.compiler.setExternalInputsFcn( ...
                simInput, @obj.setForceInput );

            % Set the post-step callback function.
            simInput = simulink.compiler.setPostStepFcn( simInput, ...
                @( simTime ) obj.onSimulationStepped( simTime ) );

            % Set the parameter values.
            simInput = simInput.setVariable( "k", obj.Stiffness, ...
                "Workspace", "MassSpringDamperModelEvents" );
            simInput = simInput.setVariable( "m", obj.Mass, ...
                "Workspace", "MassSpringDamperModelEvents" );
            simInput = simInput.setVariable( ...
                "b", obj.DampingCoefficient, ...
                "Workspace", "MassSpringDamperModelEvents" );
            simInput = simInput.setVariable( ...
                "x0", obj.InitialPosition, ...
                "Workspace", "MassSpringDamperModelEvents" );

            % Allow the model to run indefinitely.
            simInput = simInput.setModelParameter( "StopTime", "inf" );
            simInput = simulink.compiler...
                .configureForDeployment( simInput );

        end % initializeSimulationInput

        function onSimulationStatusChanged( obj, simStatus )
            %ONSIMULATIONSTATUSCHANGED Notify the event 'StatusChanged'.

            obj.SimulationStatus = simStatus;
            obj.notify( "StatusChanged" )

        end % onSimulationStatusChanged

        function onSimulationStepped( obj, simTime )
            %ONSIMULATIONSTEPPED Update the output time series and notify
            %listeners.

            obj.SimulationTime = simTime;
            obj.SimulationOutput = simulink.compiler...
                .getSimulationOutput( obj.SimulinkModelName );
            obj.OutputLog = obj.SimulationOutput.logsout...
                .extractTimetable();
            obj.OutputLog = fillmissing( obj.OutputLog, "previous" );
            obj.OutputLog.Properties.VariableNames = obj.SignalNames;
            obj.notify( "SimulationStepped" )

        end % onSimulationStepped

        function forceInput = setForceInput( obj, ~, ~ )
            %SETFORCEINPUT Set a random external force input value.

            ur01 = 0.5 * rand();
            forceInputMagnitude = 2 * obj.MaximumMagnitude * (0.5 - ur01);
            forceInput = repmat( ...
                forceInputMagnitude, 1, obj.InputChangeInterval );

        end % setForceInput

        function modifyParameterDuringSimulation( ...
                obj, paramName, paramValue )
            %MODIFYPARAMETERDURINGSIMULATION Modify the Simulink model
            %parameter when the simulation is running.

            % Exit if the simulation is neither running nor paused.
            simStatus = simulink.compiler.getSimulationStatus( ...
                obj.SimulinkModelName );
            if ~(simStatus == slsim.SimulationStatus.Running || ...
                    simStatus == slsim.SimulationStatus.Paused)
                return
            end % if

            % Modify the parameter.
            v = Simulink.Simulation.Variable( paramName, paramValue, ...
                "Workspace", obj.SimulinkModelName );
            simulink.compiler.modifyParameters( obj.SimulinkModelName, v )

        end % modifyParameterDuringSimulation

    end % methods ( Access = private )

end % classdef