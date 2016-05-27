function varargout = EventDisplay(varargin)
% EVENTDISPLAY MATLAB code for EventDisplay.fig
%      EVENTDISPLAY, by itself, creates a new EVENTDISPLAY or raises the existing
%      singleton*.
%
%      H = EVENTDISPLAY returns the handle to a new EVENTDISPLAY or the handle to
%      the existing singleton*.
%
%      EVENTDISPLAY('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in EVENTDISPLAY.M with the given input arguments.
%
%      EVENTDISPLAY('Property','Value',...) creates a new EVENTDISPLAY or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before EventDisplay_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to EventDisplay_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

    % Edit the above text to modify the response to help EventDisplay

% Last Modified by GUIDE v2.5 30-May-2015 16:43:44

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @EventDisplay_OpeningFcn, ...
                   'gui_OutputFcn',  @EventDisplay_OutputFcn, ...
                   'gui_LayoutFcn',  [] , ...
                   'gui_Callback',   []);
if nargin && ischar(varargin{1})
    gui_State.gui_Callback = str2func(varargin{1});
end

if nargout
    [varargout{1:nargout}] = gui_mainfcn(gui_State, varargin{:});
else
    gui_mainfcn(gui_State, varargin{:});
end
% End initialization code - DO NOT EDIT


% --- Executes just before EventDisplay is made visible.
function EventDisplay_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to EventDisplay (see VARARGIN)

% Choose default command line output for EventDisplay
handles.output = hObject;

% Update handles structure
guidata(hObject, handles);


% --- Outputs from this function are returned to the command line.
function varargout = EventDisplay_OutputFcn(hObject, eventdata, handles)
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;

% Updates the graph
function update(handles)
event = next(handles.data);

set(handles.Title, 'String', ['3D Run ', num2str(event.runNumber), '   Event ', num2str(event.eventNumber)]);
set(handles.Info, 'String', ['Number of Tracks: ', num2str(numel(event.tracks))]);

sketch(event);


% --- Executes on button press in RewindBut.
function RewindBut_Callback(hObject, eventdata, handles)
% hObject    handle to RewindBut (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
rewind(handles.data);
update(handles);


% --- Executes on button press in NextBut.
function NextBut_Callback(hObject, eventdata, handles)
% hObject    handle to NextBut (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
update(handles);


% --- Executes on button press in LoadBut.
function LoadBut_Callback(hObject, eventdata, handles)
% hObject    handle to LoadBut (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
filename = uigetfile('.dat');
handles.data = CdfDataFile(filename);
guidata(hObject, handles);

% sets the axii
axis([-100 100 -100 100 -100 100]); % tracking volume radius ~1m
xlabel('z [cm]'); % beamline
ylabel('x [cm]');
zlabel('y [cm]');

update(handles)
