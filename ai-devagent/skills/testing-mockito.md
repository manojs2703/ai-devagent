# Skill: Mockito -- Mocking Framework
## When to Apply This Skill
Load this skill when writing unit tests that require mocking dependencies.
---
## Setup Options
- Preferred: Annotate the test class with `@ExtendWith(MockitoExtension.class)` and use `@Mock` / `@InjectMocks` field annotations
- Alternative: Call `mock(DependencyClass.class)` manually in `@BeforeEach` when the class under test has a single constructor
- Use `@InjectMocks` to let Mockito inject all `@Mock` fields into the class under test -- Mockito tries constructor, then setter, then field injection
---
## Stubbing
- Use `when(mock.method(args)).thenReturn(value)` to stub a return value
- Use `when(mock.method(args)).thenThrow(new ExceptionType())` to stub an exception
- Use `doNothing().when(mock).voidMethod()` for void methods that should do nothing
- Use `doThrow(ExceptionType.class).when(mock).voidMethod()` for void methods that should throw
- Only stub what the test actually exercises -- do not over-stub
---
## Argument Matching
- Use exact values when the test cares about the specific argument
- Use `any()`, `anyLong()`, `anyString()` when the specific value does not matter for the behaviour being tested
- Use `argThat(predicate)` for custom matching logic
- Never mix exact values and matchers in the same stub call -- use `eq(value)` for exact-value matchers when mixing
---
## Verification
- Use `verify(mock).method(args)` to assert the mock was called with specific arguments
- Use `verify(mock, times(n)).method(args)` to assert a specific invocation count
- Use `verify(mock, never()).method(args)` to assert a method was NOT called
- Use `verifyNoMoreInteractions(mock)` at the end of a test to enforce that no unexpected calls were made
- Use `ArgumentCaptor<Type>` to capture arguments passed to a mock and then assert on them
---
## Argument Captor
- Declare `@Captor ArgumentCaptor<Type>` as a field (with `@ExtendWith(MockitoExtension.class)`) or create via `ArgumentCaptor.forClass(Type.class)` in `@BeforeEach`
- Call `verify(mock).method(captor.capture())` to capture the argument
- Retrieve the captured value with `captor.getValue()` and assert on it
---
## Spy vs Mock
- Use `@Mock` (or `mock()`) when you want complete control over all method behaviour -- all methods return defaults unless stubbed
- Use `@Spy` (or `spy()`) only when you need to stub specific methods while keeping real behaviour for others
- Avoid spies on Spring-managed beans -- prefer testing the real object directly in an integration test

