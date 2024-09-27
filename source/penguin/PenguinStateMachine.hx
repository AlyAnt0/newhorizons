package penguin;

class PenguinStateMachine
{
	public var statesDictionary:Map<String, PenguinState> = new Map<String, PenguinState>();
	public var currentState:PenguinState = null;

	public var host:Penguin = null;

	public function new(host:Penguin, initialState:String, instance:PenguinState)
	{
		this.host = host;

		addStateToList(initialState, instance);
		setState(initialState);
	}

	public function update(elapsed:Float):Void
	{
		if (currentState != null)
			currentState.update(elapsed);
	}

	public function addStateToList(stateIdentifier:String, stateInstance:PenguinState):Void {
		if (!statesDictionary.exists(stateIdentifier))
			statesDictionary.set(stateIdentifier, stateInstance);
	}
	
	public function setState(state:String):Void
	{
		if(statesDictionary.exists(state))
		{
			currentState = statesDictionary.get(state);
			currentState.onSwitch();
		}
	}
}