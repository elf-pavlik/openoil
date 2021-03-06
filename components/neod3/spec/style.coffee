describe 'neo.style', ->
  styledata =
    'node':
      'color': '#aaa'
      'border-width': '2px'
      'caption': 'Node'
    'node.Actor':
      'color': '#fff'
    'relationship':
      'color': '#BDC3C7'

  grass = """
relationship {
  color: none;
  border-color: #e3e3e3;
  border-width: 1.5px;
}

node.User {
  color: #FF6C7C;
  border-color: #EB5D6C;
  caption: '{name}';
}

node {
  diameter: 40px;
  color: #FCC940;
  border-color: #F3BA25;
}
"""

  beforeEach ->
    @style = neo.style()
    @style.loadRules(styledata)
  afterEach ->
    neo.style.defaults.autoColor = yes

  it 'generates a default stylesheet', ->
    expect(@style.toSheet()).toMatch jasmine.any(Object)

  describe 'with autoColor=true', ->
    it 'autogenerates rules from node labels when encountered', ->
      node = new neo.models.Node(1, ['Person'], {})
      @style.forNode(node)

      expect(@style.toSheet()['node.Person']).toBeDefined()


  describe 'with autoColor=false', ->
    it 'does not autogenerate rules from new node types', ->
      neo.style.defaults.autoColor = no
      node = new neo.models.Node(1, ['Person'], {})
      @style.forNode(node)
      expect(@style.toSheet()['node.Person']).not.toBeDefined()

  describe '#change', ->
    it 'should change node rules', ->
      @style.change({isNode:yes}, {color: '#bbb'})
      newColor = @style.forNode().get('color')
      expect(newColor).toBe '#bbb'

    it 'should change relationship rules', ->
      @style.change({isRelationship:yes}, {color: '#bbb'})
      newColor = @style.forRelationship().get('color')
      expect(newColor).toBe '#bbb'


  describe '#forNode:', ->
    it 'should be able to get parameters for nodes without labels', ->
      expect(@style.forNode().get('color')).toBe('#aaa')
      expect(@style.forNode().get('border-width')).toBe('2px')

    it 'should inherit rules from base node rule', ->
      expect(@style.forNode(labels: ['Actor']).get('border-width')).toBe('2px')
      expect(@style.forNode(labels: ['Movie']).get('border-width')).toBe('2px')

    it 'should apply rules when specified', ->
      expect(@style.forNode(labels: ['Actor']).get('color')).toBe('#fff')

    it 'should create new rules for labels that have not been seen before', ->
      expect(@style.forNode(labels: ['Movie']).get('color')).toBe('#DFE1E3')
      expect(@style.forNode(labels: ['Person']).get('color')).toBe('#F25A29')
      sheet = @style.toSheet()
      expect(sheet['node.Movie']['color']).toBe('#DFE1E3')
      expect(sheet['node.Person']['color']).toBe('#F25A29')

    it 'should allocate colors that are not already used by existing rules', ->
      @style.change({isNode:yes, labels: ['Person']}, {color: '#DFE1E3'})
      expect(@style.forNode(labels: ['Movie']).get('color')).toBe('#F25A29')
      sheet = @style.toSheet()
      expect(sheet['node.Person']['color']).toBe('#DFE1E3')
      expect(sheet['node.Movie']['color']).toBe('#F25A29')


    it 'should stick to first default color once all default colors have been exhausted', ->
      for i in [1..@style.defaultColors().length]
        @style.forNode(labels: ["Label #{i}"])

      @style.change({isNode:yes, labels: ['Person']}, {color: '#DFE1E3'})
      @style.change({isNode:yes, labels: ['Movie']}, {color: '#DFE1E3'})
      @style.change({isNode:yes, labels: ['Animal']}, {color: '#DFE1E3'})

  describe '#parse:', ->
    it 'should parse rules from grass text', ->
      expect(@style.parse(grass).node).toEqual(jasmine.any(Object))

  describe '#resetToDefault', ->
    it 'should reset to the default styling', ->
      @style.change({isNode:yes}, {color: '#bbb'})
      newColor = @style.forNode().get('color')
      expect(newColor).toBe '#bbb'
      @style.resetToDefault()
      color = @style.forNode().get('color')
      expect(color).toBe('#DFE1E3')