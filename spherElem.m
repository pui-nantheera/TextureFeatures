function [E] = spherElem(rad)
    str(:,:,1) = [0 0 0; 0 1 0; 0 0 0];
    str(:,:,2) = [0 1 0; 1 1 1; 0 1 0];
    str(:,:,3) = [0 0 0; 0 1 0; 0 0 0];
    
    E = zeros(2*rad+1,2*rad+1,2*rad+1);
    E(rad+1,rad+1,rad+1) = 1;
    for it = 1:rad
        E = imdilate(E,str);
    end
end