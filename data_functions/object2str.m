function [object_str] = object2str(origin, size_or_theta, type, dimension)
% OBJECT2STR Generate string equation for a geometric object
%
% Syntax:
%   object_str = object2str(origin, size_or_theta, type, dimension)
%
% Description:
%   Generates a string equation representing a geometric object that can be
%   used for shape definitions in EIDORS or other computational geometry contexts.
%
% Inputs:
%   origin        - Object position/vertices (varies by shape type)
%   size_or_theta - Size parameter or rotation angle (depends on shape)
%   type          - Shape type: 'circle', 'ellipse', 'rectangle', 'triangle'
%   dimension     - Dimension: '2d' (currently only 2D supported)
%
% Outputs:
%   object_str - String equation defining the object geometry

switch dimension
    case '2d'
        switch type
            case 'circle'
                size = size_or_theta;
                object_str = ['(x-',num2str(origin(1)),').^2+(y-',num2str(origin(2)),').^2<',num2str(size),'^2'];
            case 'ellipse'
                if isempty(size_or_theta)
                    object_str = ['((x-',num2str(origin(1)),').^2/', num2str(origin(3)) ,'^2) +((y-',num2str(origin(2)),').^2/', num2str(origin(4)),'^2)<','1'];
                else
                    theta = size_or_theta;
                    x_str = ['(x*',num2str(cos(theta)),'+','y*',num2str(sin(theta)),')'];
                    y_str = ['(y*',num2str(cos(theta)),'-','x*',num2str(sin(theta)),')'];
                    
                    object_str = ['((',x_str,'-',num2str(origin(1)),').^2/', num2str(origin(3)) ,'^2) +((',y_str,'-',num2str(origin(2)),').^2/', num2str(origin(4)),'^2)<','1'];
                end
            case 'rectangle'
                theta = size_or_theta;

                x_str = ['(x*',num2str(cos(theta)),'+','y*',num2str(sin(theta)),')'];
                y_str = ['(y*',num2str(cos(theta)),'-','x*',num2str(sin(theta)),')'];
                object_str = ['and(' ,'and(',x_str,'>',num2str(origin(1)),',',x_str,'<',num2str(origin(2)),'),','and(',y_str,'>',num2str(origin(3)),',',y_str,'<',num2str(origin(4)),')',')'];
            case 'triangle'
                theta = size_or_theta;

                x_str = ['(x*',num2str(cos(theta)),'+','y*',num2str(sin(theta)),')'];
                y_str = ['(y*',num2str(cos(theta)),'-','x*',num2str(sin(theta)),')'];
                
                m1 = (origin(4)-origin(2))/(origin(3)-origin(1));
                m2 = (origin(6)-origin(4))/(origin(5)-origin(3));
                m3 = (origin(2)-origin(6))/(origin(1)-origin(5));
                expr1 = ['(',y_str,' - ' , num2str(origin(2)) ,')-', num2str(m1),'*(',x_str,'-',num2str(origin(1)),')>0'];
                expr2 = ['(',y_str,' - ' , num2str(origin(4)) ,')-', num2str(m2),'*(',x_str,'-',num2str(origin(3)),')<0'];
                expr3 = ['(',y_str,' - ' , num2str(origin(6)) ,')-', num2str(m3),'*(',x_str,'-',num2str(origin(5)),')>0'];
                object_str = ['and(' ,expr1 ,',' ,'and(',expr2,',',expr3,'))'];

            otherwise 
                error('Shape type not yet implemented');
        end
    otherwise 
        error('Dimension not yet implemented');
end
                
end