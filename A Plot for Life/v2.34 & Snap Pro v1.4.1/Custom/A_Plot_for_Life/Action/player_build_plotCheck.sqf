if(!DZE_ActionInProgress) exitWith {};
//Check if nearby plotpoles exists
private ["_passArray","_isPole","_needText","_distance","_findNearestPoles","_findNearestPole","_IsNearPlot","_requireplot","_isLandFireDZ","_canBuildOnPlot","_nearestPole","_ownerID","_friendlies", "_playerUID"];

//defines
_isPole = _this select 0;
_requireplot = _this select 1;
_isLandFireDZ = _this select 2;

_needText = localize "str_epoch_player_246"; //text for when requirements not met
_canBuildOnPlot = false;
_nearestPole = objNull;
_ownerID = 0;
_friendlies = [];

if(_isPole) then { //check if object is plotpole and adjust distance accordingly 
	_distance = DZE_PlotPole select 1;
} else {
	_distance = DZE_PlotPole select 0;
};

// check for near plotpoles
_findNearestPoles = nearestObjects [(vehicle player), ["Plastic_Pole_EP1_DZ"], _distance]; //create an array of nearby objects that are plotpoles, nearest will always be first in array
_findNearestPole = []; //must define an empty array to avoid problems

{
	if (alive _x) then { //only look for non-destroyed plotpoles
		_findNearestPole set [(count _findNearestPole),_x]; //build an array of live plotpoles found nearby
	};
} count _findNearestPoles; //count each item in previously created array of nearby plotpoles

_IsNearPlot = count (_findNearestPole); //count our new array of non-destroyed plotpoles. Empty array will return 0

// If item is plot pole && another one exists within 45m
if(_isPole && _IsNearPlot > 0) exitWith {  DZE_ActionInProgress = false; cutText [(format [localize "str_epoch_player_44", DZE_PlotPole select 1]) , "PLAIN DOWN"]; };

if(_IsNearPlot == 0) then {

	// Allow building of plotpole or items not requiring a plot pole
	if(!(_requireplot) || _isLandFireDZ) then {
		_canBuildOnPlot = true;
	};

} else {
	// Since there are plot poles nearby we need to check ownership && friend status

	// check nearest pole only
	_nearestPole = _findNearestPole select 0;

	_buildcheck = [player, _nearestPole] call FNC_check_owner;
	_isowner = _buildcheck select 0;
	_isfriendly = _buildcheck select 1;
	if ((_isowner) || (_isfriendly)) then {
		_canBuildOnPlot = true;
	};
};

_passArray = [_IsNearPlot,_nearestPole,_ownerID,_friendlies,_distance]; //create new array and pass it to caller

// End script if item is plot pole and another one exists within defined radius
if(_isPole && _IsNearPlot > 0) exitWith { 
	DZE_ActionInProgress = false;
	cutText [(format [localize "str_epoch_player_44", DZE_PlotPole select 1]) , "PLAIN DOWN"];
	_passArray
};

if(!_canBuildOnPlot) exitWith { //end script if requirements were not met
	DZE_ActionInProgress = false;
	cutText [format[(localize "STR_EPOCH_PLAYER_135"),_needText,_distance] , "PLAIN DOWN"];
	_passArray
};
_passArray //[int,Obj,int,array]
