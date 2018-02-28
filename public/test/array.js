describe('Array', function() {

  describe('length', function() {
    it('should be 3 when the length is 3', function() {
      [1,2,3].length.should.be.equal(3)
    });
  });

  describe('indexOf', function() {    
    it('should return -1 when the value is not present', function() {
      [1,2,3].indexOf(4).should.be.equal(1)
    });
    it('should return 0 when the value is the first in the array', function() {  
      [1,2,3].indexOf(1).should.be.equal(0)
    });
    it("should tell me when I have an unimplemented test")
  });

});

