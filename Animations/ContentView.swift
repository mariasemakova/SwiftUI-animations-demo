//
//  ContentView.swift
//  Animations
//
//  Created by Maria Semakova on 15.08.2023.
//

import SwiftUI
import enum Accelerate.vDSP

struct ContentView: View {

	var body: some View {
		NavigationView {
			List {
				Section(header: Text("SwiftUI Animations")) {
					Group {
						NavigationLink(destination: AnimationTypesCombinations().navigationTitle("Combinations of different types of animations"), label: {
							Text("Combinations of different types of animations")
						})

						NavigationLink(destination: DoubleAnimation().navigationTitle("Merging animations when interrupting"), label: {
							Text("Merging animations when interrupting")
						})

						NavigationLink(destination: GeoEffectView().navigationTitle("GeometryEffect"), label: {
							Text("GeometryEffect")
						})
					}

					NavigationLink(destination: GeoEffectVSViewModifierView().navigationTitle("GeometryEffect vs ViewModifier"), label: {
						Text("GeometryEffect vs ViewModifier")
					})

					NavigationLink(destination: MatchedGeoView().navigationTitle("Matched geometry effect"), label: {
						Text("Matched geometry effect")
					})
				}

				Section(header: Text("Transitions")) {
					NavigationLink(destination: TransitionsView().navigationTitle("Transitions"), label: {
						Text("Transitions")
					})

					NavigationLink(destination: NotFriendlyModifierView().navigationTitle("Not friendly modifier"), label: {
						Text("Not friendly modifier")
					})

					NavigationLink(destination: ZStackView().navigationTitle("ZStack issues"), label: {
						Text("ZStack issues")
					})
				}

				Section(header: Text("Transactions")) {
					NavigationLink(destination: TransactionsView().navigationTitle("Transactions"), label: {
						Text("Transactions")
					})
				}

				Section(header: Text("Tips and Tricks")) {
					NavigationLink(destination: AnyViewView().navigationTitle("AnyView vs identity"), label: {
						Text("AnyView vs identity")
					})

					NavigationLink(destination: ConditionalModifierView().navigationTitle("Conditional modifier"), label: {
						Text("Conditional modifier")
					})

					NavigationLink(destination: MetalView().navigationTitle("Animation with Metal"), label: {
						Text("Animation with Metal")
					})

					//					NavigationLink(destination: AccelerateView().navigationTitle("Animation with Accelerate"), label: {
					//						Text("Animation with Accelerate")
					//					})
				}
			}
		}
	}
}

struct AnimationTypesCombinations: View {

	@State var selected1: Bool = false

	@State var selected2: Bool = false
	@State var colorSelected2: Bool = false

	var body: some View {
		RoundedRectangle(cornerRadius: 16)
			.fill(selected1 ? .mint : .pink)
			.animation(nil, value: selected1)
			.frame(width: selected1 ? 100 : 50, height: 50)
			.animation(.linear(duration: 1), value: selected1)
			.onTapGesture {
				selected1.toggle()
			}

		RoundedRectangle(cornerRadius: 16)
			.fill(colorSelected2 ? .mint : .pink)
			.frame(width: selected2 ? 250 : 50, height: 50)
			.onTapGesture {
				withAnimation(.spring()) {
					selected2.toggle()
				}
				colorSelected2.toggle()
			}
	}
}

struct DoubleAnimation: View {

	@State var angle: Angle = .degrees(0)

	var body: some View {
		VStack(spacing: 32) {
			VStack {
				Image(systemName: "globe")
					.imageScale(.large)
					.foregroundColor(.accentColor)
				Text("Hello, world!")
			}
			.rotationEffect(angle)
			//			.animation(.interpolatingSpring(mass: 10, stiffness: 1, damping: 2), value: angle)
			.animation(.linear(duration: 1), value: angle)

			Button("Tap") {
				angle += .degrees(45)
			}
		}
		.padding()
	}
}

struct GeoEffectView: View {

	@State var times = 0.0

	var body: some View {
		Rectangle()
			.fill(.purple)
			.frame(width: 100, height: 100)
			.modifier(ShakeEffect(times: times))
			.onTapGesture {
				withAnimation(.spring()) {
					times += 1
				}
			}
	}
}

struct ShakeEffect: GeometryEffect {
	var times: CGFloat = 0
	let amplitude: CGFloat = 10

	var animatableData: CGFloat {
		get { times }
		set { times = newValue }
	}

	func effectValue(size: CGSize) -> ProjectionTransform {
		ProjectionTransform(
			CGAffineTransform(
				translationX: sin(2 * times * .pi * 2) * amplitude,
				y: 0
			)
		)
	}
}

struct GeoEffectVSViewModifierView: View {

	@State var sliderValue1 : Double = 0
	@State var sliderValue2 : Double = 0

	var body: some View {
		VStack {
			Spacer()
			Text("ViewModifier + Animatable")
			Image(systemName: "smiley")
				.font(.title)
				.padding()
				.customlyRotated(offsetValue: sliderValue1)
			Slider(value: $sliderValue1, in: 0...1, step: 0.01)
			HStack {
				Button(action: {
					withAnimation(.easeInOut) {
						sliderValue1 = 0
					}
				}) {
					Text("Set to 0").padding()
				}
				Button(action: {
					withAnimation(.easeInOut) {
						sliderValue1 = 1
					}
				}) {
					Text("Set to 1").padding()
				}
			}
			Text("GeometryEffect")
			Image(systemName: "smiley")
				.font(.title)
				.padding()
				.customlyRotatedWithGeo(offsetValue: sliderValue2)
			Slider(value: $sliderValue2, in: 0...1, step: 0.01)
			HStack {
				Button(action: {
					withAnimation(.easeInOut) {
						sliderValue2 = 0
					}
				}) {
					Text("Set to 0").padding()
				}
				Button(action: {
					withAnimation(.easeInOut) {
						sliderValue2 = 1
					}
				}) {
					Text("Set to 1").padding()
				}
			}
			Spacer()
		}
		.padding()
	}
}

struct CustomRotationModifier: ViewModifier {

	var offsetValue: Double // 0...1

	var animatableData: Double {
		get { offsetValue }
		set { offsetValue = newValue }
	}

	func body(content: Content) -> some View {
		content
			.rotationEffect(Angle(radians: Double.pi*(abs(offsetValue-0.5)-0.5)))
	}
}

struct CustomRotationEffect: GeometryEffect {

	var offsetValue: Double // 0...1

	var animatableData: Double {
		get { offsetValue }
		set { offsetValue = newValue }
	}

	func effectValue(size: CGSize) -> ProjectionTransform {
		let angle = Double.pi*(abs(offsetValue-0.5)-0.5)

		let affineTransform = CGAffineTransform(translationX: size.width*0.5, y: size.height*0.5)
			.rotated(by: CGFloat(angle))
			.translatedBy(x: -size.width*0.5, y: -size.height*0.5)

		return ProjectionTransform(affineTransform)
	}
}

extension View {
	func customlyRotated(offsetValue: Double) -> some View {
		modifier(CustomRotationModifier(offsetValue: offsetValue))
	}

	func customlyRotatedWithGeo(offsetValue: Double) -> some View {
		modifier(CustomRotationEffect(offsetValue: offsetValue))
	}
}

struct MatchedGeoView: View {

	@State var allColors: [Color] = [
		.mint,
		.indigo,
		.purple,
		.red,
		.cyan,
		.pink
	]

	@State var selectedColors: [Color] = []
	@Namespace private var colorsSpace

	var body: some View {
		HStack {
			ForEach(allColors, id: \.self) { color in
				Circle()
					.fill(color)
					.matchedGeometryEffect(id: color, in: colorsSpace, properties: .frame)
					.frame(width: 55, height: 55)
					.onTapGesture {
						withAnimation {
							selectedColors.append(color)
							if let indexToRemove = allColors.firstIndex(of: color) {
								allColors.remove(at: indexToRemove)
							}
						}
					}
			}
		}
		.transition(.scale(scale: 1))

		LazyVGrid(columns: [GridItem(.adaptive(minimum: 95))]) {
			ForEach(selectedColors, id: \.self) { color in
				Rectangle()
					.fill(color)
					.matchedGeometryEffect(id: color, in: colorsSpace, properties: .frame, isSource: false)
					.frame(width: 105, height: 105)
					.onTapGesture {
						withAnimation {
							selectedColors.removeAll(where: { $0 == color})
							allColors.append(color)
						}
					}
			}
		}
	}
}

struct TransitionsView: View {

	@State var isShown: Bool = true

	var body: some View {

		VStack {
			if isShown {
				Circle()
					.fill(.mint)
					.frame(width: 100)
					.transition(
						.asymmetric(
							insertion: .blur.combined(with: .scale),
							removal: .doors.combined(with: .opacity)
						)
					)
			}

			Button("Tap") {
				withAnimation(.easeIn(duration: 1)) {
					isShown.toggle()
				}
			}
		}
	}

}

struct Blur: ViewModifier {
	let active: Bool
	func body(content: Content) -> some View {
		content
			.blur(radius: active ? 50 : 0)
		.opacity(active ? 0 : 1) }
}

struct Doors: ViewModifier {
	let shift: CGFloat
	func body(content: Content) -> some View {
		ZStack {
			content
				.clipShape(
					Circle()
						.trim(from: 0, to: 0.5)
						.rotation(.degrees(90))
				)
				.offset(x: -shift)
			content
				.clipShape(
					Circle()
						.trim(from: 0.5, to: 1)
						.rotation(.degrees(90))
				)
				.offset(x: shift)
		}
	}
}

extension AnyTransition {
	static var blur: AnyTransition {
		.modifier(active: Blur(active: true), identity: Blur(active: false))
	}

	static var doors: AnyTransition {
		.modifier(active: Doors(shift: 200), identity: Doors(shift: 0))
	}
}

struct NotFriendlyModifierView: View {

	@State var isShown = false

	var body: some View {
		VStack(spacing: 32) {
			if isShown {
				Image(systemName: "globe")
					.imageScale(.large)
					.foregroundColor(.accentColor)
					.transition(.slide)
				Text("Hello, world!")
					.transition(.slide)
			}

			Button("Tap") {
				withAnimation {
					isShown.toggle()
				}
			}
		}
		.padding()
		.rotationEffect(Angle(degrees: 45))
	}
}


struct ZStackView: View {

	@State var isShown = false

	var body: some View {
		VStack {
			ZStack {
				Color.mint

				VStack {
					if isShown {
						Text("Hello, world!")
							.transition(.slide.combined(with: .opacity))
						//												.zIndex(1)
					}
				}
			}
			.frame(width: 300, height: 300)

			Button("Tap") {
				withAnimation(.easeIn) {
					isShown.toggle()
				}
			}
		}
		.padding()
	}
}

struct TransactionsView: View {

	@State var isSelected = false
	var body: some View {
		Circle()
			.fill(isSelected ? Color.mint : Color.pink)
			.frame(width: 50, height: 50)
			.animation(.easeInOut, value: isSelected)
			.onTapGesture {
				let animation: Animation = isSelected ? .easeIn.repeatForever() : .linear(duration: 1)
				var t = Transaction(animation: animation)
				t.disablesAnimations = true
				withTransaction(t) {
					isSelected.toggle()
				}
			}
	}
}

struct AnyViewView: View {

	@State var isShown = true

	struct Ocean: Identifiable, Equatable {
		let name: String
		let id = UUID()
	}

	@State var oceans = [
		Ocean(name: "Pacific"),
		Ocean(name: "Atlantic"),
		Ocean(name: "Indian"),
		Ocean(name: "Southern"),
		Ocean(name: "Arctic")
	]

	@State var selectedOceans: [Ocean] = []

	var body: some View {

		List {
			Section("Oceans") {
				ForEach(oceans) { ocean in
					AnyView(
						Text(ocean.name)
							.contentShape(Rectangle())
							.onTapGesture {
								withAnimation {
									selectedOceans.append(ocean)
									oceans.removeAll(where: { $0 == ocean })
								}
							}
					)
				}
			}

			Section("Selected oceans") {
				ForEach(selectedOceans) { ocean in
					Text(ocean.name)
						.contentShape(Rectangle())
						.transition(.slide)
						.onTapGesture {
							withAnimation {
								oceans.append(ocean)
								selectedOceans.removeAll(where: { $0 == ocean })
							}
						}
				}
			}
		}
	}
}

struct ConditionalModifierView: View {

	@State var selected1 = false
	@State var selected2 = false

	var body: some View {

		RoundedRectangle(cornerRadius: 16)
			.fill(selected1 ? .mint : .pink)
			.if(selected1) { view in
				view.frame(width: 100, height: 200)
			}
			.onTapGesture {
				withAnimation {
					selected1.toggle()
				}
			}

		RoundedRectangle(cornerRadius: 16)
			.fill(selected2 ? .mint : .pink)
			.frame(width: selected2 ? 100 : .infinity, height: selected2 ? 200 : .infinity)
			.onTapGesture {
				withAnimation {
					selected2.toggle()
				}
			}
	}
}

extension View {

	@ViewBuilder func `if`<Content: View>(
		_ condition: @autoclosure () -> Bool,
		transform: (Self) -> Content
	) -> some View {
		if condition() {
			transform(self)
		} else {
			self
		}
	}
}


/// From https://swiftui-lab.com/swiftui-animations-part1/
struct MetalView: View {
	var body: some View {

		VStack {
			FlowerView()
				.drawingGroup()
		}.padding(20)
	}

}

struct FlowerView: View {
	@State private var animate = false

	let colors: [Color] = [.red, .orange, .yellow, .green, .blue, .purple, .pink]

	var body: some View {
		ZStack {
			ForEach(0..<7) { i in
				FlowerColor(petals: self.getPetals(i), length: self.getLength(i), color: self.colors[i])
			}
			.rotationEffect(Angle(degrees: animate ? 360 : 0))
			.onAppear {
				withAnimation(.easeInOut(duration: 3.0).repeatForever()) {
					self.animate = true
				}
			}
		}
	}

	func getLength(_ i: Int) -> Double {
		return 1 - (Double(i) * 1 / 7)
	}

	func getPetals(_ i: Int) -> Int {
		return i * 2 + 15
	}
}

struct FlowerColor: View {
	let petals: Int
	let length: Double
	let color: Color

	@State private var animate = false

	var body: some View {
		let petalWidth1 = Angle(degrees: 2)
		let petalWidth2 = Angle(degrees: 360 / Double(self.petals)) * 2

		return GeometryReader { proxy in

			ForEach(0..<self.petals) { i in
				PetalShape(angle: Angle(degrees: Double(i) * 360 / Double(self.petals)), arc: self.animate ? petalWidth1 : petalWidth2, length: self.animate ? self.length : self.length * 0.9)
					.fill(RadialGradient(gradient: Gradient(colors: [self.color.opacity(0.2), self.color]), center: UnitPoint(x: 0.5, y: 0.5), startRadius: 0.1 * min(proxy.size.width, proxy.size.height) / 2.0, endRadius: min(proxy.size.width, proxy.size.height) / 2.0))
			}

		}.onAppear {
			withAnimation(Animation.easeInOut(duration: 5).repeatForever()) {
				self.animate = true
			}
		}
	}
}

struct PetalShape: Shape {
	let angle: Angle
	var arc: Angle
	var length: Double

	var animatableData: AnimatablePair<Double, Double> {
		get { AnimatablePair(arc.degrees, length) }
		set {
			arc = Angle(degrees: newValue.first)
			length = newValue.second
		}
	}

	func path(in rect: CGRect) -> Path {
		let center = CGPoint(x: rect.midX, y: rect.midY)
		let hypotenuse = Double(min(rect.width, rect.height)) / 2.0 * length

		let sep = arc / 2

		let to = CGPoint(x: CGFloat(cos(angle.radians) * Double(hypotenuse)) + center.x,
						 y: CGFloat(sin(angle.radians) * Double(hypotenuse)) + center.y)

		let ctrl1 = CGPoint(x: CGFloat(cos((angle + sep).radians) * Double(hypotenuse)) + center.x,
							y: CGFloat(sin((angle + sep).radians) * Double(hypotenuse)) + center.y)

		let ctrl2 = CGPoint(x: CGFloat(cos((angle - sep).radians) * Double(hypotenuse)) + center.x,
							y: CGFloat(sin((angle - sep).radians) * Double(hypotenuse)) + center.y)


		var path = Path()

		path.move(to: center)
		path.addQuadCurve(to: to, control: ctrl1)
		path.addQuadCurve(to: center, control: ctrl2)

		return path
	}

}

//// From https://alexdremov.me/swiftui-advanced-animation/
//struct AccelerateView: View {
//
//	let timer = Timer.publish(every: 1, on: .main, in: .common).autoconnect()
//	@State var vector: AnimatableVector = .zero
//
//	var body: some View {
//
//		MorphingCircleShape(vector)
//			.fill(.mint)
//			.animation(.easeInOut(duration: 2), value: vector)
//			.padding()
//			.onReceive(timer) { _ in
//				let range = Float(-30)...Float(30)
//				var morphing = Array.init(repeating: Float.zero, count: 4)
//				for i in 0..<morphing.count where Int.random(in: 0...1) == 0 {
//					morphing[i] = Float.random(in: range)
//				}
//				vector = AnimatableVector(values: morphing)
//			}
//	}
//
//	struct AnimatableVector: VectorArithmetic {
//		var values: [Float]
//
//		static var zero = AnimatableVector(values: [0.0])
//
//		static func + (lhs: AnimatableVector, rhs: AnimatableVector) -> AnimatableVector {
//			let count = min(lhs.values.count, rhs.values.count)
//			return AnimatableVector(
//				values: vDSP.add(
//					lhs.values[0..<count],
//					rhs.values[0..<count]
//				)
//			)
//		}
//
//		static func += (lhs: inout AnimatableVector, rhs: AnimatableVector) {
//			let count = min(lhs.values.count, rhs.values.count)
//			vDSP.add(
//				lhs.values[0..<count],
//				rhs.values[0..<count],
//				result: &lhs.values[0..<count]
//			)
//		}
//
//		static func - (lhs: AnimatableVector, rhs: AnimatableVector) -> AnimatableVector {
//			let count = min(lhs.values.count, rhs.values.count)
//			return AnimatableVector(
//				values: vDSP.subtract(
//					lhs.values[0..<count],
//					rhs.values[0..<count]
//				)
//			)
//		}
//
//		static func -= (lhs: inout AnimatableVector, rhs: AnimatableVector) {
//			let count = min(lhs.values.count, rhs.values.count)
//			vDSP.subtract(
//				lhs.values[0..<count],
//				rhs.values[0..<count],
//				result: &lhs.values[0..<count]
//			)
//		}
//
//		mutating func scale(by rhs: Double) {
//			vDSP.multiply(
//				Float(rhs),
//				values,
//				result: &values
//			)
//		}
//
//		var magnitudeSquared: Double {
//			Double(
//				vDSP.sum(
//					vDSP.multiply(values, values)
//				)
//			)
//		}
//
//		var count: Int {
//			values.count
//		}
//
//		subscript(_ i: Int) -> Float {
//			get {
//				values[i]
//			} set {
//				values[i] = newValue
//			}
//		}
//	}
//
//	struct MorphingCircleShape: Shape {
//		let pointsNum: Int
//		var morphing: AnimatableVector
//		let tangentCoeficient: CGFloat
//
//		var animatableData: AnimatableVector {
//			get { morphing }
//			set { morphing = newValue }
//		}
//
//		// Calculates control points
//		func getTwoTangent(center: CGPoint, point: CGPoint) -> (first: CGPoint, second: CGPoint) {
//			let a = CGVector(center - point)
//			let dir = a.perpendicular() * a.len() * tangentCoeficient
//			return (point - dir, point + dir)
//		}
//
//		// Draw circle
//		func path(in rect: CGRect) -> Path {
//			var path = Path()
//			let radius = min(rect.width / 2, rect.height / 2)
//			let center =  CGPoint(x: rect.width / 2, y: rect.height / 2)
//			var nextPoint = CGPoint.zero
//
//			let ithPoint: (Int) -> CGPoint = { i in
//				let point = center + CGPoint(x: radius * sin(CGFloat(i) * CGFloat.pi * CGFloat(2) / CGFloat(pointsNum)),
//											 y: radius * cos(CGFloat(i) * CGFloat.pi * CGFloat(2) / CGFloat(pointsNum)))
//				var direction = CGVector(point - center)
//				direction = direction / direction.len()
//				return point + direction * CGFloat(morphing[i >= pointsNum ? 0 : i])
//			}
//			var tangentLast = getTwoTangent(center: center,
//											point: ithPoint(pointsNum - 1))
//			for i in (0...pointsNum){
//				nextPoint = ithPoint(i)
//				let tangentNow = getTwoTangent(center: center, point: nextPoint)
//				if i != 0 {
//					path.addCurve(to: nextPoint, control1: tangentLast.1, control2: tangentNow.0)
//				} else {
//					path.move(to: nextPoint)
//				}
//				tangentLast = tangentNow
//			}
//
//			path.closeSubpath()
//			return path
//		}
//
//
//		init(_ morph: AnimatableVector) {
//			pointsNum = morph.count
//			morphing = morph
//			tangentCoeficient = (4 / 3) * tan(CGFloat.pi / CGFloat(2 * pointsNum))
//		}
//	}
//}
//
//extension CGPoint {
//	public static func +(lhs: CGPoint, rhs: CGPoint) -> CGPoint {
//		CGPoint(x: lhs.x + rhs.x, y: lhs.y + rhs.y)
//	}
//
//	static func +(lhs: CGPoint, rhs: CGVector) -> CGPoint {
//		CGPoint(x: lhs.x + rhs.dx, y: lhs.y + rhs.dy)
//	}
//
//	static func -(lhs: CGPoint, rhs: CGVector) -> CGPoint {
//		CGPoint(x: lhs.x - rhs.dx, y: lhs.y - rhs.dy)
//	}
//
//	public static func -(lhs: CGPoint, rhs: CGPoint) -> CGPoint {
//		CGPoint(x: lhs.x - rhs.x, y: lhs.y - rhs.y)
//	}
//
//	init(_ vec: CGVector) {
//		self = CGPoint(x: vec.dx, y: vec.dy)
//	}
//}
//
//extension CGPoint: VectorArithmetic {
//	public mutating func scale(by rhs: Double) {
//		x = CGFloat(rhs) * x
//		y = CGFloat(rhs) * y
//	}
//
//	public var magnitudeSquared: Double {
//		Double(x * x + y * y)
//	}
//
//
//}
//
//extension CGVector {
//	init(_ point: CGPoint) {
//		self = CGVector(dx: point.x, dy: point.y)
//	}
//
//	func scalar(_ vec: CGVector) -> CGFloat {
//		dx * vec.dx + dy * vec.dy
//	}
//
//	func len() -> CGFloat {
//		sqrt(dx * dx + dy * dy)
//	}
//
//	func perpendicular() -> CGVector {
//		CGVector(dx: -dy, dy: dx) / len()
//	}
//
//	static func *(lhs: CGVector, rhs: CGFloat) -> CGVector {
//		CGVector(dx: lhs.dx * rhs, dy: lhs.dy * rhs)
//	}
//
//	static func *(lhs: CGFloat, rhs: CGVector) -> CGVector {
//		CGVector(dx: rhs.dx * lhs, dy: rhs.dy * lhs)
//	}
//
//	static func /(lhs: CGVector, rhs: CGFloat) -> CGVector {
//		CGVector(dx: lhs.dx / rhs, dy: lhs.dy / rhs)
//	}
//
//	static func -(lhs: CGVector, rhs: CGVector) -> CGVector {
//		CGVector(dx: lhs.dx - rhs.dx, dy: lhs.dy - rhs.dy)
//	}
//
//	static func +(lhs: CGVector, rhs: CGVector) -> CGVector {
//		CGVector(dx: lhs.dx + rhs.dx, dy: lhs.dy + rhs.dy)
//	}
//
//	func angle(_ rhs: CGVector) -> CGFloat {
//		return acos(scalar(rhs) / (rhs.len() * len()))
//	}
//}


struct ContentView_Previews: PreviewProvider {
	static var previews: some View {
		ContentView()
	}
}
