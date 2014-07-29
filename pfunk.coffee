r = require 'ramda'
_ = require 'lodash'
every = r.all(r.identity)

checkValidations = (validations, value)->
  every validations.map (v)-> v(value)

alwaysTrue = -> true

passesValidators = (args, checks)->
  passed = true
  for v,i in args
    do(i)->
      checker_list = checks[i]
      checker_list ?= [alwaysTrue]
      passed = passed && checkValidations(checker_list, v)
  return passed

SHORTHAND_TYPES = {
  "String": _.isString
  "Function": _.isFunction
  "Object": _.isObject
  "Array": _.isArray
  "Number": _.isNumber
  "*": alwaysTrue
}

pfunk = (base_fn, base_checks = {})->
  withSignature = (validators...)->
    new_registered_checks = _.cloneDeep(base_checks)
    for v, i in validators
      do(v,i)->
        if _.isString(v) and SHORTHAND_TYPES[v]?
          v = SHORTHAND_TYPES[v]
        if new_registered_checks[i]?
          new_registered_checks[i].push v
        else
          new_registered_checks[i] = [v]
    new_fn = r.arity base_fn.length, (args...)->
      if args.length > 0 and passesValidators(args, new_registered_checks)
        base_fn.apply(null, args)
      else
        throw new Error("NOPE")
    return pfunk(new_fn, new_registered_checks)

  base_fn.withSignature = withSignature
  return base_fn

registerType = (type_name, fn)->
  SHORTHAND_TYPES[type_name] = fn

pfunk.registerType = registerType

module.exports = {pfunk}
