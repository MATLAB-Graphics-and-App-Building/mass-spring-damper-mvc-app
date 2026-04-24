classdef ModelImageView < massSpringDamper.MassSpringDamperComponent
    %MODELIMAGEVIEW Display the image of the Simulink model.

    % Copyright 2025-2026 The MathWorks, Inc

    properties ( Access = private )
        % Image of the model.
        ModelImage(:, 1) matlab.ui.control.Image {mustBeScalarOrEmpty}
    end % properties ( Access = private )

    methods

        function obj = ModelImageView( model, namedArgs )
            %MODELIMAGEVIEW Construct a ModelImageView object, given
            % optional name-value pairs.

            arguments ( Input )
                model(1, 1) massSpringDamper.Model
                namedArgs.?massSpringDamper.ModelImageView
            end % arguments ( Input )

            % Call the superclass constructor.
            obj@massSpringDamper.MassSpringDamperComponent( model )

            % Update the image.
            obj.ModelImage.ImageSource = obj.Model.ImageFile;

            % Set any user-specified properties.
            set( obj, namedArgs )

        end % constructor

    end % methods

    methods ( Access = protected )

        function setup ( obj )
            %SETUP Initialize the component.

            % Create the main layout.
            mainLayout = uigridlayout( obj, [1, 1] );

            % Create the Model Image.
            obj.ModelImage = uiimage( "Parent", mainLayout );

        end % setup

        function update( ~ )
            %UPDATE Update the component. Not needed here.

        end % update

    end % methods ( Access = protected )

end % classdef