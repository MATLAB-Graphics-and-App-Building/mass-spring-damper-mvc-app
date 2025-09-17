classdef SimulationController
    %SIMULATIONCONTROLLER Provide a controller of the inputs and parameters of the simulation.

    properties ( GetAccess = protected, SetAccess = immutable )
        % Application data model.
        Model(:, 1) massSpringDamper.Model {mustBeScalarOrEmpty}
    end % properties ( GetAccess = protected, SetAccess = immutable )

    properties ( Access = private )
        % Mass Value Spinner.
        MassSpinner(1, 1) matlab.ui.control.Spinner
        % Stiffness Value Spinner.
        StiffnessSpinner(1, 1) matlab.ui.control.Spinner
        % Damping Value Spinner.
        DampingSpinner(1, 1) matlab.ui.control.Spinner
        % Initial Position Value Spinner.
        InitialPosEditField(1, 1) matlab.ui.control.EditField
    end % properties

    methods

        function obj = SimulationController( model, namedArgs )
            %SIMULATIONCONTROLLER Construct a SimulationController object, given
            %the model and optional name-value pairs.

            arguments ( Input )
                model(1, 1) massSpringDamper.Model
                namedArgs.?massSpringDamper.SimulationController
            end % arguments ( Input )

            % Assign the model.
            obj.Model = model;

            % Set any user-specified properties.
            set( obj, namedArgs )

        end % constructor

    end % methods

    methods ( Access = protected )

        function setup( obj )
            %SETUP Initialize the component.

            % Create the main layout.
            mainLayout = uigridlayout( "Parent", obj, ...
                "ColumnWidth", {"fit", "1x"}, ...
                "RowHeight", {"5x", "4x", "1x", "1x"});

            % Create the parameters Panel.
            paramPanel = uipanel(mainLayout,...
                "BackgroundColor", [0.902 0.902 0.902]);
            paramPanel.Layout.Row = 1;
            paramPanel.Layout.Column = [1, 2];

            % Create the parameters Grid Layout.
            paramGrid = uigridlayout(paramPanel,...
                "ColumnWidth", {"fit", "1x"},...
                "RowHeight", {"1x", "1x", "1x", "1x", "1x"});

            % Create the Force Input panel
            forcePanel = uipanel(mainLayout,...
                "BackgroundColor", [0.902 0.902 0.902]);
            forcePanel.Layout.Row = 2;
            forcePanel.Layout.Column = [1, 2];

            % Create the Force Input Grid Layout.
            forceGrid = uigridlayout(paramPanel,...
                "ColumnWidth", {"fit", "1x"},...
                "RowHeight", {"1x", "1x", "1x", "1x"});

            % Create the parameters Label
            paramLabel = uilabel(paramGrid,...
                "Text", "Parameters",...
                "FontWeight", "bold");
            paramLabel.Layout.Row = 1;
            paramLabel.Layout.Column = 1;

            % Create the Mass Label and Spinner.
            massLabel = uilabel(paramGrid,...
                "Text", "Mass (Kg)",...
                "FontWeight", "bold");
            massLabel.Layout.Row = 2;
            massLabel.Layout.Column = 1;

            obj.MassSpinner = uispinner(paramGrid,...
                "LowerLimitInclusive", "off",....
                "UpperLimitInclusive", "off",...
                "Limits", [0 Inf],...
                "Enable", "off",...
                "ValueChangingFcn", @obj.onMassValueChanging);
            obj.MassSpinner.Layout.Row = 2;
            obj.MassSpinner.Layout.Column = 2;

            % Create the Stiffness Label and Spinner.
            stiffnessLabel = uilabel(paramGrid,...
                "Text", "Stiffness (N/m)",...
                "FontWeight", "bold");
            stiffnessLabel.Layout.Row = 3;
            stiffnessLabel.Layout.Column = 1;

            obj.StiffnessSpinner = uispinner(paramGrid,...
                "LowerLimitInclusive", "off",...
                "UpperLimitInclusive", "off",...
                "Limits", [0 Inf],...
                "Enable", "off",...
                "ValueChangingFcn", @obj.onStiffnessValueChanging);
            obj.StiffnessSpinner.Layout.Row = 3;
            obj.StiffnessSpinner.Layout.Column = 2;

            % Create the Damping Label and Spinner.
            dampingLabel = uilabel(paramGrid,...
                "Text", "Damping (N/m/s)",...
                "FontWeight", "bold");
            dampingLabel.Layout.Row = 4;
            dampingLabel.Layout.Column = 1;

            obj.DampingSpinner = uispinner(paramGrid,...
                "LowerLimitInclusive", "off",...
                "UpperLimitInclusive", "off",...
                "Limits", [0 Inf],...
                "Enable", "off",...
                "ValueChangingFcn", @obj.onDampingValueChanging);
            obj.DampingSpinner.Layout.Row = 4;
            obj.DampingSpinner.Layout.Column = 2;

            % Create the Initial Position Label and text field.
            initialPosLabel = uilabel(paramGrid,...
                "Text", "Initial Position (m)",...
                "FontWeight", "bold");
            initialPosLabel.Layout.Row = 5;
            initialPosLabel.Layout.Column = 1;

            obj.InitialPosEditField = uieditfield(paramGrid,...
                "LowerLimitInclusive", "off",...
                "UpperLimitInclusive", "off",...
                "Tag", "DisableWhileRunning",...
                "Enable", "off");
            obj.InitialPosEditField.Layout.Row = 5;
            obj.InitialPosEditField.Layout.Column = 2;
        end
    end % methods ( Access = protected )


    methods ( Access = private )
        function onMassValueChanging (obj, s, ~)
            obj.Model.Mass = s.Value;
            obj.Model.changeMass;
        end % onMassValueChanging (obj, s, ~)

        function onStiffnessValueChanging (obj, s, ~)
            obj.Model.Stiffness = s.Value;
            obj.Model.changeStiffness;
        end % onStiffnessValueChanging (obj, s, ~)

        function onDampingValueChanging (obj, s, ~)
            obj.Model.Damping = s.Value;
            obj.Model.changeDamping;
        end % onDampingValueChanging (obj, s, ~)

    end % methods ( Access = private )

end % classdef SimulationController