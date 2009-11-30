function [x,resvec,iter,err,info]=idrs(A,b,s,tol,maxit,P,x0,Q,angle );

%IDRS Induced Dimension Reduction method
%   X = IDRS(A,B) attempts to solve the system of linear equations A*X=B
%   for X.  The N-by-N coefficient matrix A must be square and the right hand
%   side column vector B must have length N.  A may be a function returning A*X.
%
%   IDRS(A,B,S) specifies the dimension of the 'shadow space'. If S = [], then
%   IDRS uses the default S = 4. Normally, a higher S gives faster convergence, 
%   but also makes the method more expensive.
%
%   IDRS(A,B,S,TOL) specifies the tolerance of the method.  If TOL is []
%   then IDR uses the default, 1e-8.
%
%   IDRS(A,B,S,TOL,MAXIT) specifies the maximum number of iterations.  If
%   MAXIT is [] then IDR uses the default, min(2*N,1000).
%
%   IDRS(A,B,S,TOL,MAXIT,P) use preconditioner P. If P is [] then no 
%   preconditioner is applied. 
%
%   IDRS(A,B,S,TOL,MAXIT,P,X0) specifies the initial guess.  If X0 is []
%   then IDR uses the default, an all zero vector.
%
%   IDRS(A,B,S,TOL,MAXIT,P,X0,Q) specifies the shadow space. Default is 
%   an orthogonal basis for the space spanned by s random vectors
%
%   IDRS(A,B,S,TOL,MAXIT,P,X0,Q,ANGLE) Determines the value of OMEGA,
%   the parameter of the minimum residual step. If ANGLE [] then a standard
%   minimum resudual step is taken, if ANGLE > 0 then OMEGA is increased if
%   the angle between Ar and r is too small. 
%   
%   [X,RESVEC] = IDRS(A,B,S,TOL,MAXIT,P, X0,Q,ANGLE) also returns
%   a vector of the residual norms at each matrix-vector multiplication.
%   
%   [X,RESVEC, ITER] = IDRS(A,B,S,TOL,MAXIT,P,X0,Q,ANGLE) also returns
%   the number of iterations.
%
%   [X,RESVEC, ITER,ERR] = IDRS(A,B,S,TOL,MAXIT,P,X0,Q,ANGLE) also 
%   returns the measure for the error:
%          ERR = ||B - AX||/||B||
%
%   [X,RESVEC, ITER, ERR, INFO] = IDRS(A,B,S,TOL,MAXIT,P,X0,Q,ANGLE) 
%   also returns an information flag:
%       INFO = 0: required tolerance satisfied
%       INFO = 1: no convergence to the required tolerance within maximum 
%                 number of iterations
%       INFO = 2: check ERR, possible stagnation above required 
%                 tolerance level
%
%   The software is distributed without any warranty.
%
%   Martin van Gijzen and Peter Sonneveld
%   Copyright (c) December 2008

% Check for an acceptable number of input arguments
if nargin < 2
   error('Not enough input arguments.');
end

% Check matrix and right hand side vector inputs have appropriate sizes
[m,n] = size(A);
if (m ~= n)
   error('Matrix must be square.');
end
if ~isequal(size(b),[m,1])
   es = sprintf(['Right hand side must be a column vector of' ...
         ' length %d to match the coefficient matrix.'],m);
   error(es);
end

% Assign default values to unspecified parameters
if nargin < 3 | isempty(s)
   s = 4;
end
if nargin < 4 | isempty(tol)
   tol = 1e-8;
end
if nargin < 5 | isempty(maxit)
   maxit = min(2*n,1000);
end
if nargin < 6 | isempty(P)
   prec = 0;
else
   prec = 1;
   if ~isequal(size(P),[n,n])
      es = sprintf(['Preconditioner must be a matrix of' ...
            ' size %d times %d to match the problem size.'],n,n);
      error(es);
   end
end

if nargin < 7 | isempty(x0)
   x0 = zeros(n,1);
else
   if ~isequal(size(x0),[n,1])
      es = sprintf(['Initial guess must be a column vector of' ...
            ' length %d to match the problem size.'],n);
      error(es);
   end
end

if ((nargin < 8) | isempty(Q))
   rand('state', 0);
   Q = rand(n,s);
   Q = orth(Q);
else
   if ~isequal(size(Q),[n,s])
      es = sprintf(['Shadow space must have dimension' ...
            ' %d times %d to match the problem size.'],n,s);
      error(es);
   end
end

if nargin < 9 | isempty(angle)
   angle = 0.7;
end

if nargin > 9
   es = sprintf(['Too many input parameters']);
   error(es);
end

% END CHECKING INPUT PARAMETERS AND SETTING DEFAULTS

x = zeros(n,1);        
% Check for zero rhs:
if (norm(b) == 0)              % Solution is nulvector
   iter = 0;                 
   resvec = 0;
   info = 0;
   err = 0;
   return
end

% Compute initial residual:
x = x0;
tolb = tol * norm(b);           % Relative tolerance

r = b - A*x;
normr = norm(r);
resvec=[normr];

if (normr <= tolb)                 % Initial guess is a good enough solution
   iter = 0;                 
   info = 0;
   err = 0;
   return
end

G = zeros(n,s); U = zeros(n,s); M = eye(s,s); 
om = 1;

% Main iteration loop, build G-spaces:
iter = 0;
while ( normr > tolb & iter < maxit )  

% New righ-hand size for small system:
   f = (r'*Q)';
   for k = 1:s 

% Solve small system and make v orthogonal to Q:
      c = M(k:s,k:s)\f(k:s); 
      v = r - G(:,k:s)*c;
      if ( prec )
         v = P\v;
      end

      U(:,k) = U(:,k:s)*c + om*v;
% Compute G(:,k) = A U(:,k) 
      G(:,k) = A*U(:,k);
%
% Bi-Orthogonalise the new basis vectors: 
      for i = 1:k-1
         alpha =  ( Q(:,i)'*G(:,k) )/M(i,i);
         G(:,k) = G(:,k) - alpha*G(:,i);
         U(:,k) = U(:,k) - alpha*U(:,i);
      end
% New column of M = Q'*G  (first k-1 entries are zero)
      M(k:s,k) = (G(:,k)'*Q(:,k:s))';
%
%  Make r orthogonal to p_i, i = 1..k 
      beta = f(k)/M(k,k);
      r = r - beta*G(:,k);
      x = x + beta*U(:,k);

      iter = iter + 1;
      normr = norm(r);
      resvec = [resvec;normr];
      if ( normr < tolb | iter == maxit ) 
         break
      end 

% New f = Q'*r (first k  components are zero)
      if ( k <s ) 
         f(k+1:s)   = f(k+1:s) - beta*M(k+1:s,k);
      end
   end 

% Now we have sufficient vectors in G_j to compute residual in G_j+1
% Note: r is already perpendicular to Q so v = r
   v = r;
   if ( prec )
      v = P\v;
   end
   t = A*v;
   om = omega( t, r, angle );
%
   r = r - om*t;
   x = x + om*v;
   normr = norm(r);
   resvec = [resvec;normr];
   iter = iter + 1;

end; %while

err = norm( b - A*x)/norm( b );
if ( err < tol ) 
   info = 0;
elseif ( iter == maxit )
   info = 1;
else
   info = 2;
end

return

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function om = omega( t, s, angle )

ns = norm(s);
nt = norm(t);
ts = dot(t,s);
rho = abs(ts/(nt*ns));
om=ts/(nt*nt);
if ( abs(rho ) < angle )
   om = om*angle/abs(rho);
end

return
