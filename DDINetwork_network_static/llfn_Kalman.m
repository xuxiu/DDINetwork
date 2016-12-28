function llfn = llfn_Kalman(bigthet)

global yy yn maturity K; 
global mu fai AA BB DD sig omega lamda;
global sigmat_t sigmat_lag ft_lag XNS;

lamda = bigthet(end);
c1    = ones(yn, 1);
c2    = zeros(yn, 1);
c3    = zeros(yn, 1);
for i = 1 : yn
    c2(i) = (1 - exp( - lamda*maturity(i)))/(lamda*maturity(i));
    c3(i) = c2(i) - exp( - lamda*maturity(i));
end;
CC = [c1 c2 c3];
BB = CC;

bigt = length(yy);
mu   = bigthet(1 : K);
fai  = reshape(bigthet(K + 1 : K + K^2), K, K);
for i = 1 : K
    for j = 1 : K
        if j<i || (j>i && j<4) || (j>i && i>3)
            fai(i, j) = 0;
        end
    end    
end
omega = diag(bigthet(K + K^2 + 1 : K + K^2 + K));
sig   = diag(bigthet(K + K^2 + K + 1 : K + K^2 + K + yn));
lamda = bigthet(end);

% Initial parameter value
llfn     = - 0.5*yn*(bigt - 1)*log(2*pi); 
DD       = eye(K);
Xini     = (inv(eye(K, K) - fai))*mu;
Xt_t     = Xini;
inter    = eye(K^2) - kron(fai, fai');
DomegaD  = DD*omega*DD';
vecsigma = inter\eye(K^2) * DomegaD(:);
sigmat_t = reshape(vecsigma, K,  K);

for t = 1:bigt;
    Xt_lag     = mu + fai*Xt_t;
    sigmat_lag = fai*sigmat_t*fai' + DD*omega*DD';
    FF         = BB;
    itat_lag   = yy(t, :)' -  AA - FF*Xt_lag;
    ft_lag     = FF*sigmat_lag*FF' + sig;    
    if t>1  
        llfn = llfn - 0.5*log(det(ft_lag)) - 0.5*itat_lag'*(ft_lag\eye(yn))*itat_lag;
    end;    
    Kalg      = sigmat_lag*FF'*(ft_lag\eye(yn));  
    Xt_t      = Xt_lag + Kalg*itat_lag;
    sigmat_t  = sigmat_lag - Kalg*FF*sigmat_lag;
    XNS(:, t) = Xt_t;
end;

llfn = - llfn;

if omega < 0;
    llfn = real(llfn) + 1e8;
end  
if abs(imag(llfn)) > 0
    llfn = real(llfn) + 1e8;
end
  
