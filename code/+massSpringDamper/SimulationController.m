classdef SimulationController < massSpringDamper.MassSpringDamperComponent
    %SIMULATIONCONTROLLER Control simulation inputs and parameters.

    % Copyright 2025-2026 The MathWorks, Inc.

    properties ( Access = private )
        % Property listeners, for changes in the mass, stiffness, damping
        % coefficient, initial position, and input change interval
        % parameters.
        ParameterListeners(:, 1) event.proplistener
        % Simulation status listener.
        SimulationStatusListener(:, 1) event.listener {mustBeScalarOrEmpty}
    end % properties ( Access = private )

    properties ( Access = private )
        % Grid layout for the various simulation controls.
        Grid(:, 1) matlab.ui.container.GridLayout {mustBeScalarOrEmpty}
        % Controls for starting and stopping the simulation.
        StartStopControls(:, 1) simulink.ui.control.SimulationControls ...
            {mustBeScalarOrEmpty}
        % Simulation progress indicator.
        ProgressIndicator(:, 1) simulink.ui.control.SimulationProgress ...
            {mustBeScalarOrEmpty}
        % Button for saving the simulation output.
        SaveButton(:, 1) simulink.ui.control.SaveOutputButton ...
            {mustBeScalarOrEmpty}
        % Spinner controls, for tuning the mass, stiffness, damping
        % coefficient, initial position, and input change interval
        % parameters.
        Spinners(:, 1) matlab.ui.control.Spinner
    end % properties ( Access = private )

    methods

        function obj = SimulationController( model, namedArgs )
            %SIMULATIONCONTROLLER Construct a SimulationController object,
            %given the model and optional name-value pairs.

            arguments ( Input )
                model(1, 1) massSpringDamper.Model
                namedArgs.?massSpringDamper.SimulationController
            end % arguments ( Input )

            % Call the superclass constructor.
            obj@massSpringDamper.MassSpringDamperComponent( model )

            % Attach the model listeners.
            obj.ParameterListeners(1) = listener( obj.Model, ...
                "Mass", "PostSet", @obj.onMassChanged );
            obj.ParameterListeners(2) = listener( obj.Model, ...
                "Stiffness", "PostSet", @obj.onStiffnessChanged );
            obj.ParameterListeners(3) = listener( obj.Model, ...
                "DampingCoefficient", "PostSet", ...
                @obj.onDampingCoefficientChanged );
            obj.ParameterListeners(4) = listener( obj.Model, ...
                "InitialPosition", "PostSet", ...
                @obj.onInitialPositionChanged );

            % Attach the simulation status change listener.
            obj.SimulationStatusListener = listener( obj.Model.Simulation, ...
                "SimulationStatusChanged", @obj.onSimulationStatusChanged);

            % Connect the controls to the simulation object.
            set( [obj.StartStopControls, ...
                obj.ProgressIndicator, ...
                obj.SaveButton], "Simulation", obj.Model.Simulation )

            % Update the controls to reflect the model parameter values.
            obj.Spinners(1).Value = obj.Model.Mass;
            obj.Spinners(2).Value = obj.Model.Stiffness;
            obj.Spinners(3).Value = obj.Model.DampingCoefficient;
            obj.Spinners(4).Value = obj.Model.InitialPosition;            

            % Bind each spinner with the corresponding model parameter.
            % vars = obj.Model.Simulation.TunableVariables;
            % modelName = obj.Model.SimulinkModelName;
            % obj.Bindings(1) = bind( obj.Spinners(1), "Value", ...
            %     vars, "m:" + modelName );
            % obj.Bindings(2) = bind( obj.Spinners(2), "Value", ...
            %     vars, "k:" + modelName );
            % obj.Bindings(3) = bind( obj.Spinners(3), "Value", ...
            %     vars, "b:" + modelName );
            % obj.Bindings(4) = bind( obj.Spinners(4), "Value", ...
            %     vars, "x0:" + modelName );           

            % Set any user-specified properties.
            set( obj, namedArgs )

        end % constructor

    end % methods

    methods ( Access = protected )

        function setup( obj )
            %SETUP Initialize the component's graphics.

            % Create the main layout.
            obj.Grid = uigridlayout( "Parent", obj, ...
                "ColumnWidth", {100, "1x", "fit"}, ...
                "RowHeight", {50, "1x"}, ...
                "Padding", 5, ...
                "RowSpacing", 5, ...
                "ColumnSpacing", 5 );

            % Add the simulation controls.
            obj.StartStopControls = uisimcontrols( ...
                "Parent", obj.Grid );

            % Add the simulation progress bar.
            obj.ProgressIndicator = uisimprogress( ...
                "Parent", obj.Grid );

            % Add the simulation export button.
            obj.SaveButton = uisimdatabutton( ...
                "Parent", obj.Grid, ...
                "OutputFilename", "MassSpringDamperOutput.mat" );

            % Add a grid for the parameter labels and spinners.
            spinnerGrid = uigridlayout( obj.Grid, [5, 2], ...
                "RowHeight", repelem( "fit", 5 ), ...
                "ColumnWidth", ["fit", "1x"] );
            spinnerGrid.Layout.Column = [1, 3];

            % Add the parameter labels and spinners.
            uilabel( spinnerGrid, "Text", "Variable", ...
                "FontWeight", "bold" );
            uilabel( spinnerGrid, "Text", "Value", ...
                "FontWeight", "bold" );
            uilabel( spinnerGrid, "Text", "Mass (kg)" );
            obj.Spinners(1) = uispinner( spinnerGrid, ...
                "Limits", [0, Inf], ...
                "LowerLimitInclusive", "off", ...
                "UpperLimitInclusive", "off", ...
                "ValueChangedFcn", @obj.onMassEdited );
            uilabel( spinnerGrid, "Text", "Stiffness (N/m)" );
            obj.Spinners(2) = uispinner( spinnerGrid, ...
                "Limits", [0, Inf], ...
                "LowerLimitInclusive", "off", ...
                "UpperLimitInclusive", "off", ...
                "ValueChangedFcn", @obj.onStiffnessEdited );
            uilabel( spinnerGrid, "Text", "Damping Coefficient (N/m/s)" );
            obj.Spinners(3) = uispinner( spinnerGrid, ...
                "Limits", [0, Inf], ...
                "LowerLimitInclusive", "off", ...
                "UpperLimitInclusive", "off", ...
                "ValueChangedFcn", @obj.onDampingCoefficientEdited );
            uilabel( spinnerGrid, "Text", "Initial Position (m)" );
            obj.Spinners(4) = uispinner( spinnerGrid, ...
                "Limits", [0, Inf], ...
                "UpperLimitInclusive", "off", ...
                "ValueChangedFcn", @obj.onInitialPositionEdited );            

        end % setup

        function update( ~ )
            %UPDATE Update the component's graphics.

        end % update

    end % methods ( Access = protected )

    methods ( Access = private )

        function onMassEdited( obj, ~, ~ )
            %ONMASSEDITED Update the mass in the simulation object.

            obj.Model.Mass = obj.Spinners(1).Value;

        end % onMassEdited

        function onStiffnessEdited( obj, ~, ~ )
            %ONSTIFFNESSEDITED Update the stiffness in the simulation object.

            obj.Model.Stiffness = obj.Spinners(2).Value;

        end % onStiffnessEdited

        function onDampingCoefficientEdited( obj, ~, ~ )
            %ONDAMPINGCOEFFICIENTEDITED Update the damping coefficient in
            %the simulation object.

            obj.Model.DampingCoefficient = obj.Spinners(3).Value;

        end % onDampingCoefficientEdited

        function onInitialPositionEdited( obj, ~, ~ )
            %ONINITIALPOSITIONEDITED Update the initial position in the
            %simulation object.

            obj.Model.InitialPosition = obj.Spinners(4).Value;

        end % onInitialPositionEdited        

        function onMassChanged( obj, ~, ~ )
            %ONMASSCHANGED Respond to changes in the model's Mass property.

            obj.Spinners(1).Value = obj.Model.Mass;

        end % onMassChanged

        function onStiffnessChanged( obj, ~, ~ )
            %ONSTIFFNESSCHANGED Respond to changes in the model's Stiffness
            %property.

            obj.Spinners(2).Value = obj.Model.Stiffness;

        end % onStiffnessChanged

        function onDampingCoefficientChanged( obj, ~, ~ )
            %ONDAMPINGCOEFFICIENTCHANGED Respond to changes in the model's
            %DampingCoefficient property.

            obj.Spinners(3).Value = obj.Model.DampingCoefficient;

        end % onDampingCoefficientChanged

        function onInitialPositionChanged( obj, ~, ~ )
            %ONINITIALPOSITIONCHANGED Respond to changes in the model's
            %InitialPosition property.

            obj.Spinners(4).Value = obj.Model.InitialPosition;

        end % onInitialPositionChanged  

        function onSimulationStatusChanged( obj, ~, ~ )
            %ONSIMULATIONSTATUSCHANGED Respond to changes in the
            %simulation's status.

            switch obj.Model.Simulation.Status
                case "inactive"
                    obj.Spinners(4).Enable = "on";
                otherwise
                    obj.Spinners(4).Enable = "off";
            end
        end % onInitialPositionChanged        

    end % methods ( Access = private )

end % classdef