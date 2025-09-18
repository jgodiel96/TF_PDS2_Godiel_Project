function [trainedClassifierSVM, validationAccuracy] = trainClassifierSVM(datasetTable)
% Extraer predictores y respuestas
predictorNames = {'Area', 'Perimetro', 'EjePrincipal', 'EjeMenor', 'AltoLetra', 'BajoLetra'};
predictors = datasetTable(:,predictorNames);
predictors = table2array(varfun(@double, predictors));
response = datasetTable.Letra;

%ENTRENAMIENTO
%Por default itera 1e6 veces
%Se define la funcion de kernel
%fitcecoc es para la clasificacion muliticlase y se define el método one vs one
template = templateSVM('KernelFunction', 'rbf', 'KernelScale', 'auto', 'BoxConstraint', 1, 'Standardize', 1);
trainedClassifierSVM = fitcecoc(predictors, response, 'Learners', template, 'Coding', 'onevsone', 'PredictorNames', {'Area', 'Perimetro', 'EjePrincipal', 'EjeMenor', 'AltoLetra', 'BajoLetra'}, 'ResponseName', 'Letra', 'ClassNames', {'A' 'B' 'C' 'D' 'E' 'F' 'G' 'H' 'I' 'J' 'K' 'L' 'M' 'N' 'O' 'P' 'Q' 'R' 'S' 'T' 'U' 'V' 'W' 'X' 'Y' 'Z'}); 

% Validación cruzada
partitionedModel = crossval(trainedClassifierSVM, 'KFold', 5);

% Calcula la precisión de la validación
validationAccuracy = 1 - kfoldLoss(partitionedModel, 'LossFun', 'ClassifError');
