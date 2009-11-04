function [x,resvec,iter]=idrs(A,b,s,tol,maxit,x0)
% see paper in this directory
%--------------- Creating start residual: ----------
N = length(b);
x = x0;
r = b - A*x;
normr = norm(r);
tolr = tol * norm(b); % tol: relative tolerance
resvec=[normr];
if (normr <= tolr) % Initial guess is a good enough solution
    iter=0;
    return;
end;
%----------------- Shadow space: --------------------
rand('state', 0); %for reproducibility reasons.
P = rand(N,s);
P(:,1) = r; % Only for comparison with Bi-CGSTAB
P = orth(P)'; % transpose for efficiency reasons.
%---------------- Produce start vectors: ------------
dR = zeros(N,s); dX = zeros(N,s);
for k = 1:s
    v = A*r;
    om = dot(v,r)/dot(v,v);
    dX(:,k) = om*r; dR(:,k) = -om*v;
    x = x + dX(:,k); r = r + dR(:,k);
    normr = norm(r);
    resvec = [resvec;normr];
    M(:,k) = P*dR(:,k);
end
%----------------- Main iteration loop, build G-spaces: ----------------
iter = s;
oldest = 1;
m = P*r;
while ( normr > tolr ) & ( iter < maxit )
    for k = 0:s
        c = M\m;
        q = -dR*c; % s-1 updates + 1 scaling
        v = r + q; % simple addition
        if ( k == 0 ) % 1 time:
            t = A*v; % 1 matmul
            om = dot(t,v)/dot(t,t); % 2 inner products
            dR(:,oldest) = q - om*t; % 1 update
            dX(:,oldest) = -dX*c + om*v; % s updates + 1 scaling
        else %
            dX(:,oldest) = -dX*c + om*v; % s updates + 1 scaling
            dR(:,oldest) = -A*dX(:,oldest); % 1 matmul
        end
        r = r + dR(:,oldest); % simple addition
        x = x + dX(:,oldest); % simple addition
        iter = iter + 1;
        normr=norm(r); % 1 inner product (not counted)
        resvec = [resvec;normr];
        dm = P*dR(:,oldest); % s inner products
        M(:,oldest) = dm;
        m = m + dm;
        % cycling s+1 times through matrices with s columns:
        oldest = oldest + 1;
        if ( oldest > s )
            oldest = 1;
        end
    end; % k = 0:s
end; %while
return