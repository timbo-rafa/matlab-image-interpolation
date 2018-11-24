#!/usr/bin/octave -qf
function XY = scaleOrRotate(nr, nc, rad, scale)

	[X Y] = meshgrid(1:nc, 1:nr);
	if (rad)
		% rotate on center
		xcenter = ceil((nc + 1)/ 2);
		ycenter = ceil((nr + 1)/ 2);
		InterpolationMat = [ cos(rad) sin(rad) ; -sin(rad) cos(rad) ];
		XY = [X(:)-xcenter Y(:)-ycenter] * InterpolationMat;
		XY = bsxfun(@plus,XY,[xcenter ycenter]);
	else
		XY = [X(:) Y(:)] ./ scale;
	end
end

function [x y] = vizinho_core(XY)
	x = round(XY(:,1));
	y = round(XY(:,2));
end

function outImg = vizinho(rad, scale, width, height, inImg)
	[ nr nc _] = size(inImg);
	XY = scaleOrRotate(height, width, rad, scale);
	[x y] = vizinho_core(XY);
	outbound = y<1 | y>nr | x<1 | x>nc;   % check for out of bound indexes
	outbound = repmat(outbound, [1 1 3]); % on all color channels and replace it with black later
	x(x<1) = 1; x(x>nc) = nc;
	y(y<1) = 1; y(y>nr) = nr;
	x = repmat(x, [3 1]); y = repmat(y,[3 1]); % replicate 3 times for each color channel
	z=repmat(cat(3,1,2,3), [height width 1]);
	z=z(:);
	outImg = inImg(sub2ind([ nr  nc 3] , y, x, z(:))); %lookup
	outImg = reshape(outImg, [height width 3]);
	outImg(outbound) = 0; % black background
end

function outImg = bilinear(rad, scale, width, height, inImg)
	[ nr nc _] = size(inImg);
	XY = scaleOrRotate(height, width, rad, scale);
	floorXY = floor(XY);
	D = XY .- floorXY;
	dx = D(:,1);
	dy = D(:,2);
	x = floorXY(:,1);
	y = floorXY(:,2);
	outbound = x<1 | y<1 | x>nc | y>nr;
	outbound = repmat(outbound, [1 1 3]); 
	xIncrement = x .+ 1;
	yIncrement = y .+ 1; 
	x(x<1) = 1; x(x>nc) = nc; xIncrement(xIncrement<1) = 1; xIncrement(xIncrement>nc) = nc;
	y(y<1) = 1; y(y>nr) = nr; yIncrement(yIncrement<1) = 1; yIncrement(yIncrement>nc) = nc;
	x = repmat(x, [3 1]); xIncrement = repmat(xIncrement, [3 1]);
	y = repmat(y, [3 1]); yIncrement = repmat(yIncrement, [3 1]);
	dx = repmat(dx, [3 1]); dy = repmat(dy, [3 1]);
	z = repmat(cat(3,1,2,3), [height width 1]); z = z(:);
	outImg = ...
				(1 .+ -1 .* dx) .* (1 .+ -1 .* dy) .* inImg(sub2ind([nr nc 3],y, x	 			 , z(:))) ...
				.+ dx .* (1 .+ -1 .* dy) .* inImg(sub2ind([nr nc 3], y         , xIncrement, z(:))) ...
				.+ (1 .+ -1 .* dx) .* dy .* inImg(sub2ind([nr nc 3], yIncrement, x				 , z(:))) ...
				.+ dx .* dy              .* inImg(sub2ind([nr nc 3], yIncrement, xIncrement, z(:)));
	outImg = reshape(outImg, [height width 3]);
	outImg(outbound) = 0;
end

% bicubica
function t = P(t)
	t(t<=0) = 0;
end

function result = R(s)
	result = 1.0/6.0 .* ( P( s .+ 2 ) .^ 3 .- 4 .* P( s .+ 1) .^ 3 .+ 6 .* P(s) .^ 3 .- 4 .* P(s .- 1) .^ 3 );
end

function outImg = bicubica(rad, scale, width, height, inImg)
	[ nr nc _] = size(inImg);
	XY = scaleOrRotate(height, width, rad, scale);
	floorXY = floor(XY);
	D = XY - floorXY;
	dx = D(:,1);
	dy = D(:,2);
	x = floorXY(:,1);
	y = floorXY(:,2);
	outbound = x<1 | y<1 | x>nc | y>nr;
	outbound = repmat(outbound, [1 1 3]); 
	x(x>nc) = nc;
	y(y>nr) = nr;
	x = repmat(x, [3 1]);
	y = repmat(y, [3 1]);
	dx = repmat(dx, [3 1]); dy = repmat(dy, [3 1]);
	z = repmat(cat(3,1,2,3), [height width 1]); z = z(:);
	
	s = zeros(size(x));
	for m = -1 : 2
		for n = -1 : 2
			xm = x .+ m;
			yn = y .+ n;
			x(x<1) = 1; 
			y(y<1) = 1;
 			xm(xm<1) = 1; xm(xm>nc) = nc;
			yn(yn<1) = 1; yn(yn>nr) = nr;
			s = s .+ inImg(sub2ind([nr nc 3], yn, xm, z(:))) .* R(m .+ -1 .* dx) .* R(dy .- n);
		end
	end
	outImg = reshape(s, [height width 3]);
	outImg(outbound) = 0;
end

% lagrange
function result = L(x, y, dx, z, inImg)
	result = ...
		(-1 .* dx .* (dx .- 1) .* (dx .- 2) .* inImg(sub2ind(size(inImg), y,x(:,1), z(:))))/6.0 .+ ...
		((dx .+ 1) .* (dx .- 1) .* (dx .- 2).* inImg(sub2ind(size(inImg), y,x(:,2), z(:))))/2.0 .+ ...
		(-1 .* dx .* (dx .+ 1) .* (dx .- 2) .* inImg(sub2ind(size(inImg), y,x(:,3), z(:))))/2.0 .+ ...
		(dx .* (dx .+ 1) .* (dx .- 1)				.* inImg(sub2ind(size(inImg), y,x(:,4), z(:))))/6.0;
end

function outImg = lagrange(rad, scale, width, height, inImg)
	[ nr nc _] = size(inImg);
	XY = scaleOrRotate(height, width, rad, scale);
	floorXY = floor(XY);
	D = XY - floorXY;
	dx = D(:,1);
	dy = D(:,2);
	x = floorXY(:,1);
	y = floorXY(:,2);
	outbound = x<1 | y<1 | x>nc | y>nr;
	outbound = repmat(outbound, [1 1 3]); 
	x = repmat(x, [3 1]);
	y = repmat(y, [3 1]);
	xMinusOne = x .- 1; xMinusOne(xMinusOne<1) = 1 ; xMinusOne(xMinusOne>nc) = nc;
	xPlusOne = x .+ 1 ; xPlusOne(xPlusOne<1) = 1   ; xPlusOne(xPlusOne>nc) = nc;
	xPlusTwo = x .+ 2 ; xPlusTwo(xPlusTwo<1) = 1   ; xPlusTwo(xPlusTwo>nc) = nc;
	yMinusOne = y .- 1; yMinusOne(yMinusOne<1) = 1 ; yMinusOne(yMinusOne>nr) = nr;
	yPlusOne = y .+ 1 ; yPlusOne(yPlusOne<1) = 1   ; yPlusOne(yPlusOne>nr) = nr;
	yPlusTwo = y .+ 2 ; yPlusTwo(yPlusTwo<1) = 1   ; yPlusTwo(yPlusTwo>nr) = nr;
	x(x<1) = 1 ; x(x>nc) = nc;
	y(y<1) = 1 ; y(y>nr) = nr;
	dx = repmat(dx, [3 1]); dy = repmat(dy, [3 1]);
	z = repmat(cat(3,1,2,3), [height width 1]); z = z(:);

	Xs = [ xMinusOne, x, xPlusOne, xPlusTwo ];
	outImg = (-1 .* dy .* (dy .- 1) .* (dy .- 2) .* L(Xs, yMinusOne, dx, z, inImg) )/6.0 ...
		.+ ((dy .+ 1) .* (dy .- 1) .* (dy .- 2) .* L(Xs, y, dx, z, inImg))/2.0 ...
		.+ (-1 .* dy .* (dy .+ 1) .* (dy .- 2) .* L(Xs, yPlusOne, dx, z, inImg))/2.0 ...
		.+ (dy .* (dy .+ 1) .* (dy .- 1) .* L(Xs, yPlusTwo, dx, z, inImg))/6.0;
	outImg = reshape(outImg, [height width 3]);
	outImg(outbound) = 0;
end

function [rad, scale, height, width, method, inImg, output] = parameters(nargs)
	% disp 'default values';
	% angulo
	angle = 0;
	% fator de escala
	scale = 1.0;
	% largura e altura
	width = 0;
	height = 0;
	% metodo de interpolacao
	method = 'vizinho';
	% imagem de entrada
	inImg = 'house.ppm';
	% imagem de saida
	output = 'out.ppm';
	% disp 'parameters';
	arglist = argv();
	nargin = nargs
	if (nargin >= 1)
		angle = str2double(arglist{1});
	end
	if (nargin >= 2)
		scale = str2double(arglist{2});
	end
	if (nargin >= 3)
		width = str2double(arglist{3});
	end
	if (nargin >= 4)
		height = str2double(arglist{4});
	end
	if (nargin >= 5)
		method = arglist{5};
	end
	if (nargin >= 6)
		inImg = arglist{6};
	end
	if (nargin >= 7)
		output = arglist{7};
	end

	disp '==========='
	disp 'Parametros do programa'
	%print image name
	inImg

	inImg = imread(inImg);
	[ inheight inwidth  _ ] = size(inImg);
	if (scale == 1.0 && !angle)
		scale = 2.0;
		width  = 2 * inwidth;
		height = 2 * inheight;
	elseif (width == 0)
		width = inwidth;
	end
	if (height == 0)
		height = inheight;
	end
	rad = angle/180*pi;

	%print parameters
	angle, scale, width, height, method, output
end

function outImg = interpolation(method, rad, scale, width, height, inImg)
	switch method
		case 'vizinho'
			disp 'Interpolacao pelo vizinho mais proximo'
			outImg = vizinho(rad, scale, width, height, inImg);
		case 'bilinear'
			disp 'Interpolacao bilinear'
			outImg = bilinear(rad, scale, width, height, inImg);
		case 'bicubica'
			disp 'Interpolacao bicubica'
			outImg = bicubica(rad, scale, width, height, inImg);
		case 'lagrange'
			disp 'Interpolacao por polinomio de Lagrange'
			outImg = lagrange(rad, scale, width, height, inImg);
		otherwise
			disp 'Metodo de Interpolacao desconhecido'
			disp 'Os metodos aceitos sao'
			disp '  -vizinho'
			disp '  -bilinear'
			disp '  -bicubica'
			disp '  -lagrange'
			quit
	end
end

function main(nargs)
	[rad, scale, height, width, method, inImg, output] = parameters(nargs);
	outImg = interpolation(method, rad, scale, width, height, inImg);
	figure, imshow(outImg);
	imwrite(outImg,output);
	imwrite(outImg, 'ans.png');
	sleep(2)
end

 main(nargin)
