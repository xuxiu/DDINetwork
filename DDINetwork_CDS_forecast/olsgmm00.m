function [bvv, tvv, pval] = olsgmm00( lhv, rhv, lags, weight )

if size(lhv,1) ~= size(rhv,1)
    disp('Error: the length of x and y is not equal.')    
end
N       = size(lhv, 2);
[T, K]  = size(rhv);
sebv    = zeros(K, N);
Exxprim = inv((rhv'*rhv)/T);
bv      = (rhv'*rhv)\(rhv'*lhv);
errv    = lhv - rhv*bv;

% compute GMM standard errors
for indx = 1 : N;
    err = errv(:, indx);
    if (weight(indx) == 0)|(weight(indx) == 1)
        inner = (rhv.*(err*ones(1, K)))'*(rhv.*(err*ones(1, K)))/T;
        for jindx = (1 : lags(indx));
            inneradd = (rhv(1 : T - jindx, :).*(err(1 : T - jindx)*ones(1, K)))'...
                       *(rhv(1 + jindx : T, :).*(err(1 + jindx : T)*ones(1, K)))/T;
            inner    = inner + (1 - weight(indx)*jindx/(lags(indx) + 1))*(inneradd + inneradd');
        end;
    elseif weight(indx) == 2; 
        inner = rhv'*rhv/T; 
        for jindx = 1 : lags(indx); 
            inneradd = rhv(1 : T - jindx, :)'*rhv(1 + jindx : T, :)/T;
            inner    = inner + (1 - jindx/lags(indx))*(inneradd + inneradd'); 
        end; 
        inner = inner*std(err)^2;
    end; 
    varb = 1/T*Exxprim*inner*Exxprim;
    if rhv(:,1) == ones(size(rhv, 1), 1); 
        chi2val = bv(1, indx)'*inv(varb(1, 1))*bv(1, indx);
        dof     = 1;
        pval    = 1 - cdf('chi2', chi2val, dof); 
    end
    seb           = diag(varb);
    seb           = sign(seb).*(abs(seb).^0.5);
    sebv(:, indx) = seb;
end    
tv  = bv./sebv;
bvv = bv(1, :);
tvv = tv(1, :);

end

