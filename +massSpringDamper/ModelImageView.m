classdef ModelImageView < matlab.ui.componentcontainer.ComponentContainer
    %MODELIMAGEVIEW Creates the image of the Simulink model in the massSpringDamper App.

    properties ( GetAccess = protected, SetAccess = immutable )
        % Application data model.
        Model(:, 1) massSpringDamper.Model {mustBeScalarOrEmpty}
    end % properties ( GetAccess = protected, SetAccess = immutable )


    properties
        % Image of the model.
        ModelImage(1, 1) matlab.ui.control.Image
    end % properties

    properties ( Constant )
        % Image file of the model.
        ImageFile = "MassSpringDamper.svg"
    end % properties ( Constant )


    methods

        function obj = ModelImageView( model, namedArgs )
            %MODELIMAGEVIEW Construct a ModelImageView object, given
            % optional name-value pairs.

            arguments ( Input )
                model(1, 1) massSpringDamper.Model
                namedArgs.?massSpringDamper.ModelImageView
            end % arguments ( Input )

            % Assign the model.
            obj.Model = model;

            % Set any user-specified properties.
            set( obj, namedArgs )

        end % constructor

    end % methods

    methods ( Access = protected )

        function setup ( obj )
            %SETUP Initialize the component.

            % Create the main layout.
            mainLayout = uigridlayout( obj, [1, 1]);

            % Create the Model Image.
            obj.ModelImage = uiimage( ...
                "Parent", mainLayout);

            % Add the Image source.
            obj.ModelImage.ImageSource = obj.ImageFile;

        end % setup

        function update( ~ )
            %UPDATE Update the component. Not needed here.

        end % update

    end % methods ( Access = protected )


end % classdef