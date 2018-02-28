describe('AQ.Item', function() {
  describe('find', function() {
    it('should return an item', function(done) {
      AQ.Item.find(12345).then(item => {
        item.id.should.be.equal(1234);
        done();
      }).catch(response => done(response))
    });
  });
});