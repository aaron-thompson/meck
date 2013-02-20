%%%============================================================================
%%% Copyright 2010 Erlang Solutions Ltd.
%%%
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

-module(meck_call_counter_tests).

-include_lib("eunit/include/eunit.hrl").

zero_reached_test() ->
    ArgsMatcher = meck_args_matcher:new([1, '_']),
    C0 = meck_call_counter:new(foo, ArgsMatcher, '_', 3),
    C1 = meck_call_counter:update(C0, foo, [1, 2], erlang:self()),
    C2 = meck_call_counter:update(C1, foo, [1, 2], erlang:self()),
    ?assertMatch(zero_reached,
                 meck_call_counter:update(C2, foo, [1, 2], erlang:self())).

unchanged_test() ->
    ArgsMatcher = meck_args_matcher:new([1, '_']),
    Self = erlang:self(),
    Another = erlang:spawn(fun() -> ok end),
    C0 = meck_call_counter:new(foo, ArgsMatcher, Self, 3),
    ?assertMatch(unchanged,
                 meck_call_counter:update(C0, bar, [1, 2], Self)),
    ?assertMatch(unchanged,
                 meck_call_counter:update(C0, bar, [1, 2], Another)),
    ?assertMatch(unchanged,
                 meck_call_counter:update(C0, foo, [2, 3], Self)).
