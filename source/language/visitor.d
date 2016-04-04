module language.visitor;

import language.ast;

private U fastCast(U, T)(T t) if(is(T == class) && is(U == class) && is(U : T)) {
    return *(cast(U*) &t);
}

auto dispatch(
    alias unhandled = function typeof(null)(t) {
        throw new Exception(typeid(t).toString() ~ " is not supported by visitor " ~ typeid(V).toString() ~ " .");
    }, V, T
)(auto ref V visitor, T t) if(is(T == class) || is(T == interface)) {
    static if(is(T == class)) {
        alias t o;
    } else {
        auto o = cast(Object) t;
    }

    auto tid = typeid(o);

    import std.traits;
    foreach (visit; MemberFunctionsTuple!(V, "visit")) {
        alias ParameterTypeTuple!visit parameters;

        static if(parameters.length == 1) {
            alias parameters[0] parameter;

            static if(is(parameter == class) && !__traits(isAbstractClass, parameter) && is(parameter : T)) {
                if(tid is typeid(parameter)) {
                    return visitor.visit(fastCast!parameter(o));
                }
            }
        }
    }

    // Dispatch isn't possible.
    static if(is(typeof(return) == void)) {
        unhandled(t);
    } else {
        return unhandled(t);
    }
}

class Visitor {
	void visit(Ast node) {
		return this.dispatch(node);
	}
}
