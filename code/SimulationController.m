classdef SimulationController < MassSpringDamperComponent
    %SIMULATIONCONTROLLER Control simulation inputs and parameters.

    % Copyright 2025-2026 The MathWorks, Inc.

    properties ( Access = private )
        % Main grid layout.
        MainLayout(:, 1) matlab.ui.container.GridLayout ...
            {mustBeScalarOrEmpty}
        % Spinner for the mass parameter.
        MassSpinner(:, 1) matlab.ui.control.Spinner {mustBeScalarOrEmpty}
        % Spinner for the stiffness parameter.
        StiffnessSpinner(:, 1) matlab.ui.control.Spinner ...
            {mustBeScalarOrEmpty}
        % Spinner for the damping coefficient parameter.
        DampingSpinner(:, 1) matlab.ui.control.Spinner ...
            {mustBeScalarOrEmpty}
        % Spinner for the initial position of the mass.
        InitialPositionEditField(:, 1) ...
            matlab.ui.control.NumericEditField {mustBeScalarOrEmpty}
        % Button to start/stop the simulation.
        StartStopButton(:, 1) matlab.ui.control.Button ...
            {mustBeScalarOrEmpty}
        % Label for the simulation time.
        SimulationTimeLabel(:, 1) matlab.ui.control.Label ...
            {mustBeScalarOrEmpty}
    end % properties ( Access = private )

    methods

        function obj = SimulationController( model, namedArgs )
            %SIMULATIONCONTROLLER Construct a SimulationController object,
            %given the model and optional name-value pairs.

            arguments ( Input )
                model(1, 1) Model
                namedArgs.?SimulationController
            end % arguments ( Input )

            % Call the superclass constructor.
            obj@MassSpringDamperComponent( model )

            % Set any user-specified properties.
            set( obj, namedArgs )

        end % constructor

    end % methods

    methods ( Access = protected )

        function onStatusChanged( obj, ~, ~ )
            %ONSTATUSCHANGED Respond to the model event "StatusChanged".

            switch obj.Model.SimulationStatus

                case {"Initializing", "Initialized"}

                    set( [obj.MassSpinner, ...
                        obj.StiffnessSpinner, ...
                        obj.DampingSpinner, ...
                        obj.InitialPositionEditField, ...
                        obj.StartStopButton, ...                        
                        obj.SimulationTimeLabel], "Enable", "off" )
                    obj.StartStopButton.Text = "Starting simulation...";

                case "Running"

                    set( obj.StartStopButton, "Text", "Stop", ...
                        "BackgroundColor", [0.8, 0.33, 0.10] )
                    set( [obj.MassSpinner, ...
                        obj.StiffnessSpinner, ...
                        obj.DampingSpinner, ...
                        obj.StartStopButton, ...                        
                        obj.SimulationTimeLabel], "Enable", "on" )

                case "Inactive"

                    set( obj.StartStopButton, "Text", "Start", ...
                        "BackgroundColor", [0.47, 0.67, 0.19] )
                    set( [obj.MassSpinner, ...
                        obj.StiffnessSpinner, ...
                        obj.DampingSpinner, ...
                        obj.InitialPositionEditField, ...                        
                        obj.StartStopButton, ...
                        obj.SimulationTimeLabel], "Enable", "on" )

            end % switch/case

        end % onStatusChanged

        function onSimulationStepped( obj, ~, ~ )
            %ONSIMULATIONSTEPPED Respond to the model event
            %"SimulationStepped".

            obj.SimulationTimeLabel.Text = ...
                num2str( obj.Model.SimulationTime, "%.3f" );

        end % onSimulationStepped

        function setup( obj )
            %SETUP Initialize the component's graphics.

            % Create the main layout.
            obj.MainLayout = uigridlayout( "Parent", obj, ...
                "ColumnWidth", "1x", ...
                "RowHeight", ["fit", "fit"] );

            % Add a panel and grid to contain the model parameters.
            paramPanel = uipanel( obj.MainLayout, ...
                "BorderWidth", 2, ...
                "Title", "Model Parameters", ...
                "FontWeight", "bold" );
            paramGrid = uigridlayout( paramPanel, ...
                "ColumnWidth", ["fit", "1x"], ...
                "RowHeight", repelem( "fit", 4 ) );

            % Add a label and spinner for the mass.
            uilabel( paramGrid, "Text", "Mass (kg)", ...
                "FontWeight", "bold" );
            obj.MassSpinner = uispinner( paramGrid, ...
                "Limits", [0, Inf], ...
                "LowerLimitInclusive", "off", ....
                "UpperLimitInclusive", "off", ...
                "Value", 10, ...
                "ValueChangingFcn", @obj.onMassChanged );

            % Add a label and spinner for the spring stiffness.
            uilabel( paramGrid, "Text", "Stiffness (N/m)", ...
                "FontWeight", "bold" );
            obj.StiffnessSpinner = uispinner( paramGrid, ...
                "Limits", [0, Inf], ...
                "LowerLimitInclusive", "off", ...
                "UpperLimitInclusive", "off", ...
                "Value", 100, ...
                "ValueChangingFcn", @obj.onStiffnessChanged);

            % Add a label and spinner for the damping coefficient.
            uilabel( paramGrid, "Text", "Damping Coefficient (N/m/s)", ...
                "FontWeight", "bold" );
            obj.DampingSpinner = uispinner( paramGrid, ...
                "Limits", [0, Inf], ...
                "LowerLimitInclusive", "off",...
                "UpperLimitInclusive", "off",...
                "Value", 1, ...
                "ValueChangingFcn", @obj.onDampingCoefficientChanged );

            % Add a label and edit field for the initial position.
            uilabel( paramGrid, "Text", "Initial Position (m)", ...
                "FontWeight", "bold" );
            obj.InitialPositionEditField = uieditfield( paramGrid, ...
                "numeric", ...
                "Limits", [0, Inf], ...
                "LowerLimitInclusive", "on", ...
                "UpperLimitInclusive", "off", ...
                "Tag", "DisableWhileRunning", ...
                "Value", 0 );

            % Add a panel and grid for the model status.
            modelPanel = uipanel( obj.MainLayout, ...
                "BorderWidth", 2, ...
                "Title", "Model Status", ...
                "FontWeight", "bold" );
            modelGrid = uigridlayout( modelPanel, ...
                "ColumnWidth", ["fit", "1x"], ...
                "RowHeight", repelem( "fit", 3 ) );

            % Add the start/stop button.
            uilabel( modelGrid, "Text", "Simulation", ...
                "FontWeight", "bold" );
            obj.StartStopButton = uibutton( modelGrid, ...
                "BackgroundColor", [0.47, 0.67, 0.19], ...
                "FontWeight", "bold", ...
                "Text", "Start", ...
                "ButtonPushedFcn", @obj.onStartStopButtonPushed );
            uilabel( modelGrid, "Text", "Simulation Time (s)", ...
                "FontWeight", "bold" );
            obj.SimulationTimeLabel = uilabel( modelGrid, ...
                "HorizontalAlignment", "right", ...
                "Text", "" );

        end % setup

        function update( ~ )
            %UPDATE Update the component's graphics.

        end % update

    end % methods ( Access = protected )

    methods ( Access = private )

        function onMassChanged( obj, ~, ~ )
            %ONMASSCHANGED Change the mass parameter in the Simulink model.

            obj.Model.Mass = obj.MassSpinner.Value;

        end % onMassChanged

        function onStiffnessChanged( obj, ~, ~ )
            %ONSTIFFNESSCHANGED Change the stiffness parameter in the
            %Simulink model.

            obj.Model.Stiffness = obj.StiffnessSpinner.Value;

        end % onStiffnessChanged

        function onDampingCoefficientChanged( obj, ~, ~ )
            %ONDAMPINGCOEFFICIENT Change the damping coefficient parameter
            %in the Simulink model.

            obj.Model.DampingCoefficient = obj.DampingSpinner.Value;

        end % onDampingCoefficientChanged

        function onStartStopButtonPushed( obj, ~, ~ )
            %ONSTARTSTOPBUTTONPUSHED Start/stop the Simulink simulation.

            switch obj.Model.SimulationStatus
                case "Inactive"
                    obj.Model.startSimulation()
                case "Running"
                    obj.Model.stopSimulation()
            end % switch/case

        end % onStartStopButtonPushed

    end % methods ( Access = private )

end % classdef