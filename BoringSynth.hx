interface IComponent {
    public function setInput(index:Int, value:Float):Void;
    public function getOutput(channel:Int):Float;
    public function process():Void;
    public function getNumInputs():Int;
    public function getNumOutputs():Int;
    public function getInput(index:Int):Float;
    
    public function getName():String; // returns the name of this component
    public function getInputName(index:Int):String; // returns the name of the specified input
    public function getOutputName(index:Int):String; // returns the name of the specified output
}

class MatrixMixer {
    var components:Array<IComponent>;
    var weights:Array<Array<Float>>;
    var numOutputs:Int;
    var numInputs:Int;
    var inputNames:Array<String>;
    var outputNames:Array<String>;

    public function new(components:Array<IComponent>) {
        this.components = components;
        this.numOutputs = 0;
        this.numInputs = 0;
        this.inputNames = new Array<String>();
        this.outputNames = new Array<String>();

        // Calculate the total number of inputs and outputs and store names
        for (component in components) {
            for (i in 0...component.getNumOutputs()) {
                this.outputNames.push(component.getOutputName(i));
            }
            for (i in 0...component.getNumInputs()) {
                this.inputNames.push(component.getInputName(i));
            }
            this.numOutputs += component.getNumOutputs();
            this.numInputs += component.getNumInputs();
        }

        // Initialize the weights matrix
        this.weights = new Array<Array<Float>>();
        for (i in 0...numOutputs) {
            var row:Array<Float> = new Array<Float>();
            for (j in 0...numInputs) {
                row.push(0.0);
            }
            this.weights.push(row);
        }
    }

    public function setWeight(outputIndex:Int, inputIndex:Int, value:Float):Void {
        weights[outputIndex][inputIndex] = value;
    }

    public function process():Void {
        var outputs:Array<Float> = [];
        for (component in components) {
            component.process();
            for (i in 0...component.getNumOutputs()) {
                outputs.push(component.getOutput(i));
            }
        }

        var inputs:Array<Float> = [];
        for (i in 0...numInputs) {
            inputs.push(0.0);
        }

        for (i in 0...inputs.length) {
            for (j in 0...outputs.length) {
                inputs[i] += weights[j][i] * outputs[j];
            }
        }

        var inputIndex = 0;
        for (component in components) {
            for (i in 0...component.getNumInputs()) {
                component.setInput(i, inputs[inputIndex++]);
            }
        }
    }

    public function printInputOutputTable():Void {
        trace("Input Names:");
        for (i in 0...inputNames.length) {
            trace(i + ": " + inputNames[i]);
        }
        
        trace("Output Names:");
        for (i in 0...outputNames.length) {
            trace(i + ": " + outputNames[i]);
        }
    }
}


///////////////////////////////////////////////////// OSCILLATORS ///////////////////////////////////////////////////////////

class VCO implements IComponent {
    var inputs:Array<Float>;
    var phase:Float;
    var sampleRate:Int;
    var name:String;

    public function new(sampleRate:Int, name:String) {
        this.sampleRate = sampleRate;
        this.phase = 0;
        this.inputs = [0.0]; // One input for frequency
        this.name = name;
    }

    public function setInput(index:Int, value:Float):Void {
        inputs[index] = value;
    }

    public function getOutput(channel:Int):Float {
        return Math.sin(phase);
    }

    public function process():Void {
        var frequency:Float = inputs[0];
        phase += (2 * Math.PI * frequency) / sampleRate;
        if (phase >= 2 * Math.PI) {
            phase -= 2 * Math.PI;
        }
    }

    public function getNumInputs():Int {
        return 1;
    }

    public function getNumOutputs():Int {
        return 2;
    }

    public function getInput(index:Int):Float {
        return inputs[index];
    }

    public function getName():String {
        return name;
    }

    public function getInputName(index:Int):String {
        return name + ":frequency";
    }

    public function getOutputName(index:Int):String {
        return name + (index == 0 ? ":left" : ":right");
    }
}


class Saw implements IComponent {
    var inputs:Array<Float>;
    var phase:Float;
    var sampleRate:Int;
    var name:String;

    public function new(sampleRate:Int, name:String) {
        this.sampleRate = sampleRate;
        this.phase = 0;
        this.inputs = [0.0]; // One input for frequency
        this.name = name;
    }

    public function setInput(index:Int, value:Float):Void {
        inputs[index] = value;
    }

    public function getOutput(channel:Int):Float {
        return 2.0 * (phase / (2.0 * Math.PI)) - 1.0;
    }

    public function process():Void {
        var frequency:Float = inputs[0];
        phase += (2 * Math.PI * frequency) / sampleRate;
        if (phase >= 2 * Math.PI) {
            phase -= 2 * Math.PI;
        }
    }

    public function getNumInputs():Int {
        return 1;
    }

    public function getNumOutputs():Int {
        return 2;
    }

    public function getInput(index:Int):Float {
        return inputs[index];
    }

    public function getName():String {
        return name;
    }

    public function getInputName(index:Int):String {
        return name + ":frequency";
    }

    public function getOutputName(index:Int):String {
        return name + (index == 0 ? ":left" : ":right");
    }
}

class Square implements IComponent {
    var inputs:Array<Float>;
    var phase:Float;
    var sampleRate:Int;
    var name:String;

    public function new(sampleRate:Int, name:String) {
        this.sampleRate = sampleRate;
        this.phase = 0;
        this.inputs = [0.0, 0.5]; // Two inputs for frequency and pulse-width
        this.name = name;
    }

    public function setInput(index:Int, value:Float):Void {
        inputs[index] = value;
    }

    public function getOutput(channel:Int):Float {
        var pulseWidth:Float = (inputs[1] + 1) / 2; // Normalize pulse width to [0, 1]
        return (phase / (2.0 * Math.PI)) < pulseWidth ? 1.0 : -1.0;
    }

    public function process():Void {
        var frequency:Float = inputs[0];
        phase += (2 * Math.PI * frequency) / sampleRate;
        if (phase >= 2 * Math.PI) {
            phase -= 2 * Math.PI;
        }
    }

    public function getNumInputs():Int {
        return 2;
    }

    public function getNumOutputs():Int {
        return 2;
    }

    public function getInput(index:Int):Float {
        return inputs[index];
    }

    public function getName():String {
        return name;
    }

    public function getInputName(index:Int):String {
        return name + (index == 0 ? ":frequency" : ":pulseWidth");
    }

    public function getOutputName(index:Int):String {
        return name + (index == 0 ? ":left" : ":right");
    }
}

///////////////////////////////////////////////////// AMP //////////////////////////////////////////////////////////////////

class Amp implements IComponent {
    var inputs:Array<Float>;
    var name:String;

    public function new(name:String) {
        this.inputs = [0.0, 0.0, 1.0]; // Left, right, and multiplier inputs
        this.name = name;
    }

    public function setInput(index:Int, value:Float):Void {
        inputs[index] = value;
    }

    public function getOutput(channel:Int):Float {
        return inputs[channel] * inputs[2]; // Multiply left/right input by multiplier
    }

    public function process():Void {
        // No internal state to update
    }

    public function getNumInputs():Int {
        return 3;
    }

    public function getNumOutputs():Int {
        return 2;
    }

    public function getInput(index:Int):Float {
        return inputs[index];
    }

    public function getName():String {
        return name;
    }

    public function getInputName(index:Int):String {
        return name + (index == 0 ? ":left" : (index == 1 ? ":right" : ":multiplier"));
    }

    public function getOutputName(index:Int):String {
        return name + (index == 0 ? ":left" : ":right");
    }
}

///////////////////////////////////////////////////// FILTERS ///////////////////////////////////////////////////////////////////

class LPF implements IComponent {
    var inputs:Array<Float>;
    var sampleRate:Int;
    var name:String;

    // Internal filter state
    var buf0:Array<Float>;
    var buf1:Array<Float>;

    public function new(sampleRate:Int, name:String) {
        this.sampleRate = sampleRate;
        this.inputs = [0.0, 0.0, 440.0, 0.5]; // Left, right, cutoff frequency, and resonance
        this.name = name;
        this.buf0 = [0.0, 0.0];
        this.buf1 = [0.0, 0.0];
    }

    public function setInput(index:Int, value:Float):Void {
        inputs[index] = value;
    }

    public function getOutput(channel:Int):Float {
        return buf1[channel];
    }

    public function process():Void {
        var cutoff:Float = 2.0 * Math.sin(Math.PI * Math.min(0.25, inputs[2] / (sampleRate * 2.0)));
        var res:Float = Math.pow(10.0, 1.0 - inputs[3]);

        for (i in 0...2) {
            buf0[i] += cutoff * (inputs[i] - buf0[i] + res * (buf0[i] - buf1[i]));
            buf1[i] += cutoff * (buf0[i] - buf1[i]);
        }
    }

    public function getNumInputs():Int {
        return 4;
    }

    public function getNumOutputs():Int {
        return 2;
    }

    public function getInput(index:Int):Float {
        return inputs[index];
    }

    public function getName():String {
        return name;
    }

    public function getInputName(index:Int):String {
        switch(index) {
            case 0: return name + ":left";
            case 1: return name + ":right";
            case 2: return name + ":cutoff";
            case 3: return name + ":resonance";
            default: return "";
        }
    }

    public function getOutputName(index:Int):String {
        return name + (index == 0 ? ":left" : ":right");
    }
}


///////////////////////////////////////////////////// INFRASTRUCTURE ///////////////////////////////////////////////////////

class DAC implements IComponent {
    public var inputs:Array<Float>;
    var name:String;

    public function new(name:String) {
        this.inputs = [0.0, 0.0]; // Two inputs for left and right channels
        this.name = name;
    }

    public function setInput(index:Int, value:Float):Void {
        inputs[index] = value;
    }

    public function getOutput(channel:Int):Float {
        return 0.0; // DAC doesn't produce output
    }

    public function process():Void {
        // In a real implementation, this would render the inputs as audio
    }

    public function getNumInputs():Int {
        return 2;
    }

    public function getNumOutputs():Int {
        return 0;
    }

    public function getInput(index:Int):Float {
        return inputs[index];
    }

    public function getName():String {
        return name;
    }

    public function getInputName(index:Int):String {
        return name + (index == 0 ? ":left" : ":right");
    }

    public function getOutputName(index:Int):String {
        return ""; // DAC doesn't have outputs
    }
}

class Value implements IComponent {
    var value:Float;
    var name:String;

    public function new(value:Float, name:String) {
        this.value = value;
        this.name = name;
    }

    public function setInput(index:Int, value:Float):Void {
        // No inputs for Value component
    }

    public function getOutput(channel:Int):Float {
        return value;
    }

    public function process():Void {
        // Nothing to process, value is constant
    }

    public function getNumInputs():Int {
        return 0;
    }

    public function getNumOutputs():Int {
        return 2; // Outputs the value to both left and right channels
    }

    public function getInput(index:Int):Float {
        return 0.0; // No inputs, always return 0
    }

    public function getName():String {
        return name;
    }

    public function getInputName(index:Int):String {
        return ""; // No inputs
    }

    public function getOutputName(index:Int):String {
        return name + (index == 0 ? ":left" : ":right");
    }
}


