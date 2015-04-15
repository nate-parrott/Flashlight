# JRSwizzle

## Description

JRSwizzle is source code package that offers a single, easy, correct+consistent interface for exchanging Objective-C method implementations ("method swizzling") across many versions of Mac OS X, iOS, Objective-C and runtime architectures.

More succinctly: *JRSwizzle wants to be your one-stop-shop for all your method swizzling needs.*

## Download

	$ cd /path/to/top/of/your/project
	$ git submodule add git://github.com/rentzsch/jrswizzle.git JRSwizzle
	$ git submodule init && git submodule update
	
	# OPTIONAL: Execute the following commands if you want to explicitly peg
	# to a certain version. Otherwise `git submodule update` will keep you
	# current with HEAD.
	
	$ cd JRSwizzle
	$ git checkout v1.0

## Reasons for Existence

* **Easy:** Just do this: `[SomeClass jr_swizzle:@selector(foo) withMethod:@selector(my_foo) error:&error];` Voila.
* **Correct:** There's a subtle interaction between method swizzling and method inheritance. Following in Kevin Ballard's footsteps, this package Does The Right Thing.
* **Compatible:** JRSwizzle should Just Work on any version of Mac OS X and iOS you care about. Here's the exhaustive compatibility list:
	* Mac OS X v10.3/ppc (Ballard implementation)
	* Mac OS X v10.4/ppc (Ballard implementation)
	* Mac OS X v10.4/i386 (Ballard implementation)
	* Mac OS X v10.5/ppc (method_exchangeImplementations+Ballard implementation)
	* Mac OS X v10.5/i386 (method_exchangeImplementations+Ballard implementation)
	* Mac OS X v10.5/ppc64 (method_exchangeImplementations+Ballard implementation)
	* Mac OS X v10.5/x86_64 (method_exchangeImplementations+Ballard implementation)
	* iOS 2.0+ (method_exchangeImplementations+Ballard implementation)
* **Robust:** All parameters are checked and JRSwizzle returns an optional `NSError` with high-quality diagnostics.

## Support

Please use [JRSwizzle's GitHub Issues tab](https://github.com/rentzsch/jrswizzle/issues) to [file bugs or feature requests](https://github.com/rentzsch/jrswizzle/issues/new).

To contribute, please fork this project, make+commit your changes and then send me a pull request.

## Comparison

There's at least four swizzling implementations floating around. Here's a comparison chart to help you make sense of how they relate to each other and why JRSwizzle exists.

<table>
	<tr>
		<th>Scenario</th>
		<th>Swizzle Technology</th>
		<th>Method Implementation</th>
		<th>Correct Behavior</th>
		<th>10.4</th>
		<th>64-bit</th>
	</tr>
	<tr>
		<td>1</td>
		<td>Classic</td>
		<td>Direct</td>
		<td>YES</td>
		<td>YES</td>
		<td>NO</td>
	</tr>
	<tr>
		<td>2</td>
		<td>Classic</td>
		<td>Inherited</td>
		<td>NO</td>
		<td>YES</td>
		<td>NO</td>
	</tr>
	<tr>
		<td>3</td>
		<td>Ballard</td>
		<td>Direct</td>
		<td>YES</td>
		<td>YES</td>
		<td>NO</td>
	</tr>
	<tr>
		<td>4</td>
		<td>Ballard</td>
		<td>Inherited</td>
		<td>YES</td>
		<td>YES</td>
		<td>NO</td>
	</tr>
	<tr>
		<td>5</td>
		<td>Apple</td>
		<td>Direct</td>
		<td>YES</td>
		<td>NO</td>
		<td>YES</td>
	</tr>
	<tr>
		<td>6</td>
		<td>Apple</td>
		<td>Inherited</td>
		<td>NO</td>
		<td>NO</td>
		<td>YES</td>
	</tr>
	<tr>
		<td>7</td>
		<td>JRSwizzle</td>
		<td>Direct</td>
		<td>YES</td>
		<td>YES</td>
		<td>YES</td>
	</tr>
	<tr>
		<td>8</td>
		<td>JRSwizzle</td>
		<td>Inherited</td>
		<td>YES</td>
		<td>YES</td>
		<td>YES</td>
	</tr>
</table>

 * *Classic* is the canonical `MethodSwizzle()` implementation as described in [CocoaDev's MethodSwizzling page](http://www.cocoadev.com/index.pl?MethodSwizzling).
 * *Ballard* is [Kevin Ballard's improved implementation](http://kevin.sb.org/2006/12/30/method-swizzling-reimplemented/) which solves the inherited  method problem.
 * *Apple* is 10.5's new `method_exchangeImplementations` API.
 * *JRSwizzle* is this package.

## License

The source code is distributed under the nonviral [MIT License](http://opensource.org/licenses/mit-license.php). It's the simplest most permissive license available.

## Version History

* **v1.0:** Mar 2 2012

	* [NEW] iOS Support. ([Anton Serebryakov](https://github.com/rentzsch/jrswizzle/commit/60ccb350a3577e55d00d3fdfee8b3c0390b8e852]))

	* [NEW] Class method swizzling. ([outis](https://github.com/rentzsch/jrswizzle/pull/1))

* **v1.0d1:** May 31 2009

	* [FIX] Soothe valgrind by nulling out `hoisted_method_list->obsolete`, which it apparently reads. ([Daniel Jalkut](http://github.com/rentzsch/jrswizzle/commit/2f677d063202b443ca7a1c46e8b67d67ea6fc88e))

	* [FIX] Xcode 3.2 apparently now needs `ARCHS` set explicitly for 10.3 targets. ([rentzsch](http://github.com/rentzsch/jrswizzle/commit/4478faa40e4fdb322201da20f24d3996193ea48b))

* **v1.0d0:** Apr 09 2009

	* Moved to github.

* **v1.0d0:** Dec 28 2007

	* Under development.