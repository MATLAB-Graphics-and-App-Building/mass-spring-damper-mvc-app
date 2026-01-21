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
    end % properties

    properties ( Constant )
        % Simulink model name.
        SimulinkModelName(1, 1) string = "MassSpringDamperModel"
        % Model image file.
        ImageFile(1, 1) string {mustBeFile} = "MassSpringDamper.svg"
    end % properties ( Constant )

    properties ( SetAccess = private )
        % Simulation input object.
        SimulationInput(1, 1) Simulink.SimulationInput
        % Simulation output object.
        SimulationOutput(1, 1) Simulink.SimulationOutput
        % Simulation time.
        SimulationTime(1, 1) double {mustBeNonnegative, mustBeFinite} = 0
        % External force data.
        ExternalForceData(1, :) timeseries
        % Position data.
        PositionData(1, :) timeseries
        % Velocity data.
        VelocityData(1, :) timeseries
        % Acceleration data.
        AccelerationData(1, :) timeseries
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

        function obj = Model()
            %MODEL Construct the model.

            load_system( obj.SimulinkModelName )

        end % constructor

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

        function set.Mass( obj, value )

            obj.Mass = value;
            obj.modifyParameterDuringSimulation( "m", obj.Mass )

        end % set.Mass

        function set.Stiffness( obj, value )

            obj.Stiffness = value;
            obj.modifyParameterDuringSimulation( "k", obj.Stiffness )

        end % set.Stiffness

        function set.DampingCoefficient( obj, value )

            obj.DampingCoefficient = value;
            obj.modifyParameterDuringSimulation( "b", obj.DampingCoefficient )

        end % set.DampingCoefficient

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
                "Workspace", "MassSpringDamperModel" );
            simInput = simInput.setVariable( "m", obj.Mass, ...
                "Workspace", "MassSpringDamperModel" );
            simInput = simInput.setVariable( ...
                "b", obj.DampingCoefficient, ...
                "Workspace", "MassSpringDamperModel" );
            simInput = simInput.setVariable( ...
                "x0", obj.InitialPosition, ...
                "Workspace", "MassSpringDamperModel" );

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

        function forceInput = setForceInput( obj, ~, simTime )
            %SETFORCEINPUT Set a constant external force input value.

            forceInput = 5;
            %obj.ExternalForceData.Time = simTime;
            %obj.ExternalForceData.Data = forceInput;

        end % setForceInput

        function onSimulationStepped( obj, simTime )
            %ONSIMULATIONSTEPPED Update the output time series and notify
            %listeners.

            obj.SimulationTime = simTime;
            obj.SimulationOutput = simulink.compiler...
                .getSimulationOutput( obj.SimulinkModelName );
            outLog = obj.SimulationOutput.logsout;
            obj.ExternalForceData = outLog{1}.Values;
            obj.PositionData = outLog{2}.Values;
            obj.VelocityData = outLog{3}.Values;
            obj.AccelerationData = outLog{4}.Values;
            obj.notify( "SimulationStepped" )

        end % onSimulationStepped

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
            v = Simulink.Simulation.Variable( paramName, paramValue );
            simulink.compiler.modifyParameters( obj.SimulinkModelName, v )
            switch paramName
                case "m"
                    obj.Mass = paramValue;
                case "k"
                    obj.Stiffness = paramValue;
                case "b"
                    obj.DampingCoefficient = paramValue;
            end % switch/case

        end % modifyParameterDuringSimulation

    end % methods ( Access = private )

end % classdef