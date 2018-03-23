(* ::Package:: *)

(* ::Title:: *)
(*Impermanence*)

(* ::Text:: *)
(*version 0.6.1 of March 23, 2018*)

(* ::Text:: *)
(*Copyright 2018 Roman Schmied*)

(* ::Text:: *)
(*Inspiration from the Entropy language (https://esolangs.org/wiki/Entropy) via Matteo Fadel*)

(* ::Text:: *)
(*This program is free software: you can redistribute it and/or modify it under the terms of the GNU General Public License as published by the Free Software Foundation, either version 3 of the License, or (at your option) any later version.*)

(* ::Text:: *)
(*This program is distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU General Public License for more details.*)

(* ::Text:: *)
(*You should have received a copy of the GNU General Public License along with this program.  If not, see <http://www.gnu.org/licenses/>.*)


(* ::Section:: *)
(*change log*)

(* ::Text:: *)
(*0.1	2018/1/8		first packaged version*)

(* ::Text:: *)
(*0.2	2018/1/10	different types: number, tensor, string*)
(*				error messaging upon assignment to unsupported type*)

(* ::Text:: *)
(*0.3	2018/1/15	added documentation (Wolfram Application format)*)
(*				changed name from DiffusingVariables to Impermanence*)

(* ::Text:: *)
(*0.4	2018/1/24	added complex variables (numbers and tensors)*)
(*				changed the attribute of ImpermanenceVersion from ReadProtected to Protected*)
(*				added attributes for MakeImpermanentVariable: Locked, Protected, ReadProtected*)
(*				added comments on MachinePrecision limitations and Zeno effect*)

(* ::Text:: *)
(*0.5	2018/1/31	packaged value-getting functionality into ImpermanentVariableGet*)
(*				packaged value-setting functionality into ImpermanentVariableSet and ImpermanentVariableSetArray*)
(*				added ReadProtected attribute to every impermanent variable*)
(*				use HoldForm[x] instead of ToString[Unevaluated[x]] to print Set error message*)
(*				use ClearAll[x] instead of Clear[x] before making new definitions to x*)
(*				block delayed assignments to impermanent variables (typical rookie mistake)*)
(*				map TagSet and TagSetDelayed to Set and SetDelayed*)
(*				protect impermanent-variable symbols from accidental modification other than through Set*)
(*					--> now requires Dynamic[Refresh[x, ...]] for dynamic display since protected symbols aren't auto-refreshed*)
(*				updated documentation (Scope) of Set and SetDelayed*)

(* ::Text:: *)
(*0.6	2018/2/6		added Tutorial*)
(*				edited documentation*)
(*				added initialization facility to MakeImpermanentVariable, with default argument zero*)

(* ::Text:: *)
(*0.6.1	2018/3/23	minor documentation fix*)


(* ::Section:: *)
(*prolog*)

BeginPackage["Impermanence`"]

ImpermanenceVersion = "0.6.1";
SetAttributes[ImpermanenceVersion,{Locked,Protected}]


(* ::Section:: *)
(*help declarations*)

ImpermanenceVersion::usage =
	"ImpermanenceVersion "~~
	"gives the version number of the Impermanence package.";

MakeImpermanentVariable::usage =
	"MakeImpermanentVariable[x, \[ScriptCapitalD]] "~~
	"defines a variable x, initialized to zero, whose value diffuses at a rate \[ScriptCapitalD] (in units of inverse seconds of AbsoluteTime).\n"~~
	"MakeImpermanentVariable[x, \[ScriptCapitalD], \*SubscriptBox[x,0]] "~~
	"initializes the variable to \*SubscriptBox[x,0] instead.\n"~~
	"MakeImpermanentVariable[{x,y,z,\[Ellipsis]}, \[ScriptCapitalD]] "~~
	"defines several diffusing variables at the same time, with equal diffusion constant \[ScriptCapitalD]; all initialized to zero.\n"~~
	"MakeImpermanentVariable[{x,y,z,\[Ellipsis]}, \[ScriptCapitalD], \*SubscriptBox[x,0]] "~~
	"initializes each variable to \*SubscriptBox[x,0] instead.";

(* ::Section:: *)
(*start package code*)

Begin["`Private`"]


(* ::Section:: *)
(*package definitions*)

(* ::Text:: *)
(*error messages*)

MakeImpermanentVariable::type="The right-hand side of the assignment `1` = `2` is not of one of the supported types.";
MakeImpermanentVariable::setdelayed="Delayed assignments to impermanent variables (`1` := ...) are forbidden. Use an immediate assignment instead (`1` = ...).";

(* ::Text:: *)
(*prevent all these functions from evaluating their first argument, which is the name of the impermanent variable:*)

SetAttributes[{MakeImpermanentVariable,
	ImpermanentVariableD,
	ImpermanentVariableTime,
	ImpermanentVariableValue,
	ImpermanentVariableRetrieveFunction,
	ImpermanentVariableSetArray,
	ImpermanentVariableSet,
	ImpermanentVariableGet},
		HoldFirst];

(* ::Text:: *)
(*general function to set the value of an impermanent variable x to an array:*)
(*y is the value to set, in the form of a numeric tensor of arbitrary rank that will be diffused element-wise*)
(*f is the function that, when applied to y, gives the desired form of output*)

ImpermanentVariableSetArray[x_Symbol, y_/;ArrayQ[y,_,NumericQ], f_] := Module[{},
	(* unprotect x to allow modification of upvalues *)
	Unprotect[x];
	(* store the value y *)
	ImpermanentVariableValue[x] ^= y;
	(* store the function to retrieve the number *)
	ImpermanentVariableRetrieveFunction[x] ^= f;
	(* remember when this happened *)
	ImpermanentVariableTime[x] ^= AbsoluteTime[];
	(* protect to forbid further modification *)
	Protect[x];
	(* return the stored value, like the standard Set command *)
	f[y]]
ImpermanentVariableSetArray[x_Symbol, $Failed, _] := Module[{},
	Unprotect[x];
	ImpermanentVariableValue[x] ^= $Failed;
	Protect[x];
	$Failed]

(* ::Text:: *)
(*general function to set the value of an impermanent variable:*)
(*this is a type-specific wrapper for ImpermanentVariableSetArray*)
(* adding more storage types would be done here*)

(* number: store internally as a length-1 vector (real) or a length-2 vector (complex) *)
ImpermanentVariableSet[x_Symbol, y_?NumericQ] := With[{n=N[y]},
	If[Head[n]===Complex,
		ImpermanentVariableSetArray[x, ReIm[n], #.{1,I}&],		(* complex-valued variable *)
		ImpermanentVariableSetArray[x, {Re[n]}, First]]];			(* real-valued variable *)
(* array (tensor): store internally as-is (real) or as {Re,Im} pairs (complex) *)
ImpermanentVariableSet[x_Symbol, y_/;ArrayQ[y,_,NumericQ]] := With[{n=N[y]},
	If[MemberQ[Head/@Flatten[n], Complex],						(* complex if at least one element is complex *)
		ImpermanentVariableSetArray[x, ReIm[n], #.{1,I}&],		(* complex-valued array *)
		ImpermanentVariableSetArray[x, Re[n], Identity]]];		(* real-valued array *)
(* string: store internally as a vector of character codes *)
(* retrieve by rounding to nearest integer, and *)
(* roll over from 255 to 0 *)
ImpermanentVariableSet[x_Symbol, y_String] :=
	ImpermanentVariableSetArray[x, ToCharacterCode[y]+1/2, FromCharacterCode[Floor[Mod[#,256]]]&];
(* assignments of other types fail *)
ImpermanentVariableSet[x_Symbol, y_] := Module[{},
	Message[MakeImpermanentVariable::type, HoldForm[x], y];
	ImpermanentVariableSetArray[x, $Failed, Identity]];

(* ::Text:: *)
(*get the value of an impermanent variable, and apply diffusion*)

ImpermanentVariableGet[x_Symbol] := Module[{t,dt,xx},
	(* check if valid *)
	If[ImpermanentVariableValue[x]===$Failed, Return[$Failed]];
	(* now *)
	t = AbsoluteTime[];
	(* time interval elapsed since last access, in seconds *)
	dt = t - ImpermanentVariableTime[x];
	(* find new value by random diffusion of every component *)
	xx = ImpermanentVariableValue[x]+
		Sqrt[2*ImpermanentVariableD[x]*dt]*RandomVariate[NormalDistribution[],Dimensions[ImpermanentVariableValue[x]]];
	(* remember this event as the starting point of the next diffusion *)
	Unprotect[x];
	ImpermanentVariableValue[x] ^= xx;
	ImpermanentVariableTime[x] ^= t;
	Protect[x];
	(* return the new value after filtering it through the desired retrieval function *)
	ImpermanentVariableRetrieveFunction[x][xx]]

(* ::Text:: *)
(*define a diffusing variable with diffusion constant d:*)
(*we're intentionally leaving d's type unspecified, so that the user can play with this*)
(*x0 is the initial value, defaulting to zero*)

MakeImpermanentVariable[x_Symbol, d_, x0_:0] := Module[{},
	(* make sure there are no previous definitions associated with the symbol *)
	Unprotect[x]; ClearAll[x];
	(* remember the diffusion constant *)
	ImpermanentVariableD[x] ^= d;
	(* the definition for setting the variable's value *)
	x /: Set[x, y_] := ImpermanentVariableSet[x,y];
	(* the definition for getting the variable's value *)
	(* this is where the diffusion will happen *)
	x := ImpermanentVariableGet[x];
	(* prevent the user from making delayed assignments to x *)
	x /: SetDelayed[x, _] := Message[MakeImpermanentVariable::setdelayed, HoldForm[x]];
	(* map TagSet to Set and TagSetDelayed to SetDelayed *)
	(* Why is this not done by default? *)
	x /: TagSet[x, x, y_] := Set[x,y];
	x /: TagSetDelayed[x, x, y_] := SetDelayed[x,y];
	(* hide ugly definitions of x *)
	(* the user can still see them by using ClearAttributes[x, ReadProtected] or by looking at UpValues[x] and OwnValues[x] *)
	(* also, prevent the user from accidentally modifying x by means other than Set, SetDelayed, TagSet, TagSetDelayed *)
	SetAttributes[x, {Protected,ReadProtected}];
	(* initialize the variable using the just-defined Set command *)
	(* let this fail through Set if x0 is invalid *)
	x = x0;]

(* ::Text:: *)
(*define several diffusing variables with equal diffusion constant:*)

MakeImpermanentVariable[L_List, d_, x0_:0] :=
	MakeImpermanentVariable[#,d,x0]& /@ Unevaluated /@ Unevaluated[L]


(* ::Section:: *)
(*epilog*)

End[]

(* ::Text:: *)
(*prevent modifications of the public functions:*)

SetAttributes[MakeImpermanentVariable,{Locked,Protected,ReadProtected}]

EndPackage[]