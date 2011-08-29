GlobalCounter.increment!

RailsIOC::Dependencies.define do
  singleton :counter, GlobalCounter.count
end