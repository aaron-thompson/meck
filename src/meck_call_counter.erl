%%%============================================================================
%%% Licensed under the Apache License, Version 2.0 (the "License");
%%% you may not use this file except in compliance with the License.
%%% You may obtain a copy of the License at
%%%
%%% http://www.apache.org/licenses/LICENSE-2.0
%%%
%%% Unless required by applicable law or agreed to in writing, software
%%% distributed under the License is distributed on an "AS IS" BASIS,
%%% WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
%%% See the License for the specific language governing permissions and
%%% limitations under the License.
%%%============================================================================

%%% @hidden
%%% @doc Implements a call countdown counter. Used to check if a particular
%%% function call has been made a particular number of times.
-module(meck_call_counter).

-export_type([call_counter/0]).

%% API
-export([new/4,
         update/4]).

%%%============================================================================
%%% Definitions
%%%============================================================================

-record(call_counter, {opt_func :: '_' | atom(),
                       args_matcher :: meck_args_matcher:args_matcher(),
                       opt_caller_pid :: '_' | pid(),
                       countdown :: non_neg_integer()}).

%%%============================================================================
%%% Types
%%%============================================================================

-opaque call_counter() :: #call_counter{}.

%%%============================================================================
%%% API
%%%============================================================================

-spec new(OptFunc::'_' | atom(),
          meck_args_matcher:args_matcher(),
          OptCallerPid::'_' | atom(),
          Initial::non_neg_integer()) ->
        call_counter().
new(OptFunc, ArgsMatcher, OptCallerPid, Initial)
  when erlang:is_number(Initial) andalso Initial > 0 ->
    #call_counter{opt_func = OptFunc,
                  args_matcher = ArgsMatcher,
                  opt_caller_pid = OptCallerPid,
                  countdown = Initial}.

-spec update(call_counter(), Func::atom(), Args::[any()], CallerPid::pid()) ->
        unchanged | zero_reached | call_counter().
update(#call_counter{opt_func = OptFunc,
                     args_matcher = ArgsMatcher,
                     opt_caller_pid = OptCallerPid,
                     countdown = Countdown} = Counter,
       Func, Args, CallerPid)
  when (OptFunc =:= '_' orelse Func =:= OptFunc) andalso
       (OptCallerPid =:= '_' orelse CallerPid =:= OptCallerPid) ->
    case meck_args_matcher:match(Args, ArgsMatcher) of
        false ->
            unchanged;
        true when Countdown == 1 ->
            zero_reached;
        true ->
            Counter#call_counter{countdown = Countdown - 1}
    end;
update(_Counter, _Func, _Args, _CallerPid) ->
    unchanged.
