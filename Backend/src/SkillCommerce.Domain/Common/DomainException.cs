namespace SkillCommerce.Domain.Common;

/// <summary>
/// Domain exception for invariant violations and invalid state transitions.
/// Maps to HTTP 422 Unprocessable Entity via the GlobalExceptionHandler.
/// </summary>
public sealed class DomainException : Exception
{
    public string ErrorCode { get; }

    public DomainException(string errorCode, string message)
        : base(message)
    {
        ErrorCode = errorCode;
    }

    public DomainException(string errorCode, string message, Exception inner)
        : base(message, inner)
    {
        ErrorCode = errorCode;
    }
}
