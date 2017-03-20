fullpath = mfilename('fullpath');
disp(fullpath)
folder = strfind(fullpath, '\');
path = fullpath(1:folder(end));
disp(path)