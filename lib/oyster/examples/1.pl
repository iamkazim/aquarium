###########################################################
# Places
#

place p1
  protocol: "plankton/one.pl"
  group: "admin"
  marked: true
end

place p2
  protocol: "plankton/one.pl"
  group: "klavins"
  marked: false
end

###########################################################
# Transitions
#

[ p1 ] => [ p2 ] when completed(0) end
[ p1 ] => [ p2 ] when completed(0) end
  
###########################################################
# Wires
#

(p1,"n") => (p2,"x")
