r = require 'ramda'
_ = require 'lodash'

fTake = (n, list)->
  nList = []
  for i in [0...n]
    nList.push list[i]
  return nList

checkValidations = (validations, value)->
  for fn in validations
    if not fn(value) then return false
  return true

ALWAYS_TRUE = -> true
THROW_IT = (er)-> throw er
UNDEF = -> undefined

passesValidators = (args, checks)->
  passed = true
  for v, i in args
    checker_list = checks[i]
    checker_list ?= [ALWAYS_TRUE]
    passed = passed && checkValidations(checker_list, v)
  return passed

REGISTERED_TYPES = {
  "String": _.isString
  "Function": _.isFunction
  "Object": _.isObject
  "Array": _.isArray
  "Number": _.isNumber
  "*": ALWAYS_TRUE
}

pfunk = (base_fn, failure = ((e)-> e), base_checks = {})->
  base_fn.withSignature = (validators...)->
    new_registered_checks = _.cloneDeep(base_checks)
    for v, i in validators
      do(v,i)->
        if _.isString(v) and REGISTERED_TYPES[v]?
          v = REGISTERED_TYPES[v]
        if new_registered_checks[i]?
          new_registered_checks[i].push v
        else
          new_registered_checks[i] = [v]
    new_fn = r.arity base_fn.length, (args...)->
      num_args_to_check = Math.max(base_fn.length, args.length)
      args_to_check = fTake(num_args_to_check, args)
      if args.length > 0 and passesValidators(args_to_check, new_registered_checks)
        return base_fn.apply(null, args)
      else
        return failure(new Error("BAD ARGS: #{args}"))
    return pfunk(new_fn, failure, new_registered_checks)
  return base_fn

pfunk.strong = (base_fn, base_checks = {})->
  pfunk(base_fn, THROW_IT, base_checks)

pfunk.loose = (base_fn, base_checks = {})->
  pfunk(base_fn, UNDEF, base_checks)

pfunk.registerType = (type_name, fn)->
  REGISTERED_TYPES[type_name] = fn

module.exports = {pfunk}
