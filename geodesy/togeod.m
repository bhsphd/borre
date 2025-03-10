function [dphi,dlambda,h] = togeod(a,finv,X,Y,Z)
%TOGEOD Computing geodetic coordinates
%	     latitude, longitude, height given Cartesian
%	     coordinates X,Y,Z, and reference ellipsoid
%   	  values semi-major axis (a) and the inverse
%	     of flattening (finv).
%       The units of linear parameters X,Y,Z,a must all agree
%       (m,km,mi,ft,..etc). The output units of angular quantities
%       will be in decimal degrees (15.5 degrees not 15 deg 30 min). 
%       The output units of h will be the same as the units of 
%       X,Y,Z,a.

%Kai Borre 03-30-1996
%Copyright (C) 1987 C. Goad, Columbus, Ohio
%$Revision: 1.0 $  $Date:1998/10/23  $

h = 0;
tolsq = 1.e-10;
maxit = 10;
% compute radians-to-degree factor
rtd = 180/pi;
% compute square of eccentricity
if finv < 1.e-20
   esq = 0; 
else 
   esq = (2-1/finv)/finv;  
end
oneesq = 1-esq;
% first guess
% P is distance from spin axix
P = sqrt(X^2+Y^2);
% direct calculation of longitude
if P > 1.e-20
   dlambda = atan2(Y,X)*rtd;
else
   dlambda = 0; 
end;
if (dlambda < 0)
   dlambda = dlambda + 360; 
end
% r is distance from origin (0,0,0)
r = sqrt(P^2+Z^2);
if r > 1.e-20
   sinphi = Z/r;
else
   sinphi = 0;
end
dphi = asin(sinphi);
% initial value of height  =  distance from origin minus
% approximate distance from origin to surface of ellipsoid
if r < 1.e-20
    h = 0;
    break;
end;
h = r-a*(1-sinphi*sinphi/finv);
% iterate
for i = 1:maxit
	 sinphi = sin(dphi);
	 cosphi = cos(dphi);
	 % compute radius of curvature in prime vertical direction
	 N_phi = a/sqrt(1-esq*sinphi*sinphi);
	 % compute residuals in P and Z
	 dP = P - (N_phi + h) * cosphi;
	 dZ = Z - (N_phi*oneesq + h) * sinphi;
	 % update height and latitude
	 h = h+(sinphi*dZ+cosphi*dP);
	 dphi = dphi+(cosphi*dZ-sinphi*dP)/(N_phi + h);
	 % test for convergence
    if (dP*dP + dZ*dZ < tolsq)
       break
    end

	 % Not Converged--Warn user
	 if i == maxit
	      fprintf([' Problem in TOGEOD, did not converge in %2.0f',...
                                                   ' iterations\n'],i)
    end;
end;
dphi = dphi*rtd;
%%%%%%%% end togeod.m  %%%%%%%%%%%%%%%%%%%%%%
