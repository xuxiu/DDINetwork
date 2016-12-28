function [ network2 ] = VARdecompfactor(factor, plott, horizon)
ns            = factor;
[nobs, nfirm] = size(ns);
plag          = 2;
K             = nfirm;        % Variables
yt            = ns(plag + 1 : nobs, :)';
m             = K + plag*(K^2);        
tau           = nobs - plag;
Zt            = [];
for i = plag + 1 : nobs
    ztemK = eye(K);
    for j = 1:plag;
        xlag  = ns(i-j, 1:K);
        xtemK = zeros(K, K*K);
        for jj = 1 : K;
            xtemK(jj, (jj-1)*K + 1 : jj*K) = xlag;
        end
        ztemK = [ztemK xtemK];
    end
    Zt = [Zt; ztemK];
end

vbar = zeros(m, m);
xhy  = zeros(m, 1);
for i = 1 : tau
    zhat1 = Zt((i-1)*K + 1 : i*K, :);
    vbar  = vbar + zhat1'*zhat1;
    xhy   = xhy + zhat1'*yt(:, i);
end
vbar  = inv(vbar);
aols  = vbar*xhy;
sse2  = zeros(K, K);
error = zeros(K, tau);
for i = 1 : tau
    zhat1 = Zt((i - 1)*K + 1 : i*K, :);
    sse2  = sse2 + (yt(:,i) - zhat1*aols)*(yt(:,i) - zhat1*aols)';
    error(:, i) = yt(:,i) - zhat1*aols;
end
error = error';
hbar  = sse2./tau;

vbar = zeros(m, m);
for i = 1 : tau
    zhat1 = Zt((i - 1)*K + 1 : i*K, :);
    vbar = vbar + zhat1'*inv(hbar)*zhat1;
end
vbar = inv(vbar);

gamma = zeros(nfirm, 1 + K*plag);  % K = nfirm
gamma = reshape(aols, K, (1 + K*plag));
Sigma_U = hbar;
if all(eig((Sigma_U + Sigma_U')/2)) >= 0
    disp('Sigma_U is positive definite')
else
    error('Sigma_U must be positive definite')
end

F1 = gamma(:, 2 : end);
if plag > 1
    F2    = cell(1, plag - 1);
    F2{:} = deal(sparse(eye(K)));
    F2    = blkdiag(F2{:});
    F2    = full(F2);
    F3    = zeros(K*(plag - 1), K);
    F     = [F1; F2, F3];
    clear F1 F2 F3
else
    F     = F1;
    clear F1 Q1
end
if max(abs(eig(F))) < 1 
    disp('VAR is stationary')
else
    disp('VAR is not stationary!')
end

%% 
h                  = 24;               % Horizon
P                  = chol(Sigma_U);    % Cholesky decomposition
P                  = P';              
capJ               = zeros(K, K*plag);
capJ(1 : K, 1 : K) = eye(K);
Iresp              = zeros(K, K, h);
Iresp(:, :, 1)     = P;
for j = 1 : h - 1
    temp = (F^j);
    Iresp(:, :, j + 1) = capJ*temp*capJ'*P;
end
clear temp

MSE   = zeros(K, h);
CONTR = zeros(K, K, h);
for j = 1 : h
    % Compute MSE
    temp2 = eye(K);
    for i = 1 : K
        if j == 1
            MSE(i, j) = temp2(:, i)'*Iresp(:, :, j)*Sigma_U*Iresp(:, :, j)'*temp2(:, i);
            for k = 1 : K
                CONTR(i, k, j) = ((temp2(:, i)'*Iresp(:, :, j)*Sigma_U*temp2(:, k))^2)/Sigma_U(k, k);
            end
        else
            MSE(i, j) = MSE(i, j - 1) + temp2(:, i)'*Iresp(:, :, j)*Sigma_U*Iresp(:, :, j)'*temp2(:, i);
            for k = 1 : K
                CONTR(i, k, j) = CONTR(i, k, j - 1) + ((temp2(:, i)'*Iresp(:, :, j)*Sigma_U*temp2(:, k))^2)/Sigma_U(k, k);    
            end
        end
    end
end

VD = zeros(K, h, K);
for k = 1 : K
    VD(:,:,k) = squeeze(CONTR(:, k, :))./MSE;       
end
clear temp2 CONTR MSE

if plott == 1
    figure
    for i = 1 : K
        for j = 1 : K
            subplot(K, K, (j - 1)*K + i)
            plot(squeeze(VD(i, :, j)), 'Linewidth', 2)
            hold on
            plot(zeros(1, h), 'k')
            xlim([1 h])
            set(gca,'XTick', 0 : ceil(h/4) : h)
        end
    end
end

% network
h       = horizon;
net     = squeeze(VD(:, h, :));
netadj  = net./kron(ones(1, K), sum(net, 2));
net     = netadj;
netFrom = sum(net, 2) - diag(net);
netTo   = sum(net, 1) - diag(net)';
netsum  = (sum(sum(net)) - sum(diag(net)))/K;
network(1 : K, 1 : K) = net;
network(1 : K, K + 1) = netFrom;
network(K + 1, 1 : K) = netTo;
network(K + 1, 1 + K) = netsum;
network(K + 2, 1 : K) = netTo - netFrom';
network2 = 100*network;        % percent
end
