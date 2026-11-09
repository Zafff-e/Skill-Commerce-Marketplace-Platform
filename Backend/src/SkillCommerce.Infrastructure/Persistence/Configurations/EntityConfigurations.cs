using Microsoft.EntityFrameworkCore;
using Microsoft.EntityFrameworkCore.Metadata.Builders;
using SkillCommerce.Domain.Billing;
using SkillCommerce.Domain.Bookings;
using SkillCommerce.Domain.Identity;
using SkillCommerce.Domain.Jobs;
using SkillCommerce.Domain.Notifications;
using SkillCommerce.Domain.Providers;
using SkillCommerce.Domain.Reviews;
using SkillCommerce.Domain.Taxonomy;

namespace SkillCommerce.Infrastructure.Persistence.Configurations;

public sealed class ApplicationUserConfiguration : IEntityTypeConfiguration<ApplicationUser>
{
    public void Configure(EntityTypeBuilder<ApplicationUser> builder)
    {
        builder.Property(u => u.FullName).HasMaxLength(120).IsRequired();
        builder.Property(u => u.ProfilePhotoUrl).HasMaxLength(500);

        builder.HasOne(u => u.ProviderProfile)
            .WithOne(p => p.User)
            .HasForeignKey<ProviderProfile>(p => p.UserId)
            .OnDelete(DeleteBehavior.Restrict);
    }
}

public sealed class ProviderProfileConfiguration : IEntityTypeConfiguration<ProviderProfile>
{
    public void Configure(EntityTypeBuilder<ProviderProfile> builder)
    {
        builder.HasKey(p => p.Id);
        builder.HasIndex(p => p.UserId).IsUnique();
        builder.HasIndex(p => p.NIDNumber).IsUnique().HasFilter("[NIDNumber] IS NOT NULL");

        builder.Property(p => p.Bio).HasMaxLength(1000);
        builder.Property(p => p.PayoutAccount).HasMaxLength(100);
        builder.Property(p => p.OverallRating).HasPrecision(3, 2);
        builder.Property(p => p.Status).HasConversion<string>().HasMaxLength(30);

        builder.Property(p => p.BaseLocation).HasColumnType("geography");
        builder.Property(p => p.RowVersion).IsRowVersion();
    }
}

public sealed class ProviderSkillConfiguration : IEntityTypeConfiguration<ProviderSkill>
{
    public void Configure(EntityTypeBuilder<ProviderSkill> builder)
    {
        builder.HasKey(ps => ps.Id);
        builder.HasIndex(ps => new { ps.ProfileId, ps.SkillId }).IsUnique();

        // Exactly one primary skill per provider
        builder.HasIndex(ps => ps.ProfileId)
            .IsUnique()
            .HasFilter("[IsPrimary] = 1");

        builder.Property(ps => ps.CustomRate).HasPrecision(18, 2);

        builder.HasOne(ps => ps.Skill)
            .WithMany()
            .HasForeignKey(ps => ps.SkillId)
            .OnDelete(DeleteBehavior.Restrict);
    }
}

public sealed class VerificationDocumentConfiguration : IEntityTypeConfiguration<VerificationDocument>
{
    public void Configure(EntityTypeBuilder<VerificationDocument> builder)
    {
        builder.HasKey(d => d.Id);
        builder.Property(d => d.DocType).HasConversion<string>().HasMaxLength(30);
        builder.Property(d => d.DocNumber).HasMaxLength(100);
        builder.Property(d => d.FileKey).HasMaxLength(250).IsRequired();
        builder.Property(d => d.ReviewStatus).HasConversion<string>().HasMaxLength(30);
        builder.Property(d => d.ReviewNote).HasMaxLength(500);
    }
}

public sealed class TaxonomyConfiguration :
    IEntityTypeConfiguration<SkillCategory>,
    IEntityTypeConfiguration<SkillSet>,
    IEntityTypeConfiguration<Product>
{
    public void Configure(EntityTypeBuilder<SkillCategory> builder)
    {
        builder.HasKey(c => c.Id);
        builder.HasIndex(c => c.CategoryName).IsUnique();
        builder.Property(c => c.CategoryName).HasMaxLength(120).IsRequired();
        builder.Property(c => c.IconUrl).HasMaxLength(250);
        builder.Property(c => c.Description).HasMaxLength(500);
    }

    public void Configure(EntityTypeBuilder<SkillSet> builder)
    {
        builder.HasKey(s => s.Id);
        builder.HasIndex(s => new { s.CategoryId, s.SkillName }).IsUnique();
        builder.Property(s => s.SkillName).HasMaxLength(150).IsRequired();
        builder.Property(s => s.BasicPrice).HasPrecision(18, 2);
        builder.Property(s => s.ServiceUnit).HasConversion<string>().HasMaxLength(30);

        builder.HasOne(s => s.Category)
            .WithMany(c => c.Skills)
            .HasForeignKey(s => s.CategoryId)
            .OnDelete(DeleteBehavior.Restrict);
    }

    public void Configure(EntityTypeBuilder<Product> builder)
    {
        builder.HasKey(p => p.Id);
        builder.Property(p => p.Name).HasMaxLength(200).IsRequired();
        builder.Property(p => p.Brand).HasMaxLength(100);
        builder.Property(p => p.Unit).HasMaxLength(50);
        builder.Property(p => p.ReferencePrice).HasPrecision(18, 2);

        builder.HasOne(p => p.Category)
            .WithMany()
            .HasForeignKey(p => p.CategoryId)
            .OnDelete(DeleteBehavior.Restrict);
    }
}

public sealed class JobConfiguration : IEntityTypeConfiguration<Job>
{
    public void Configure(EntityTypeBuilder<Job> builder)
    {
        builder.HasKey(j => j.Id);
        builder.Property(j => j.Title).HasMaxLength(200).IsRequired();
        builder.Property(j => j.Description).HasMaxLength(2000);
        builder.Property(j => j.AddressText).HasMaxLength(300).IsRequired();
        builder.Property(j => j.VoiceNoteKey).HasMaxLength(250);
        builder.Property(j => j.Budget).HasPrecision(18, 2);
        builder.Property(j => j.Status).HasConversion<string>().HasMaxLength(30);
        builder.Property(j => j.ServiceLocation).HasColumnType("geography").IsRequired();
        builder.Property(j => j.RowVersion).IsRowVersion();

        builder.HasIndex(j => new { j.Status, j.ExpiresAtUtc });
    }
}

public sealed class ProposalConfiguration : IEntityTypeConfiguration<Proposal>
{
    public void Configure(EntityTypeBuilder<Proposal> builder)
    {
        builder.HasKey(p => p.Id);
        builder.HasIndex(p => new { p.JobId, p.ProfileId }).IsUnique();

        // Exactly one accepted proposal per job
        builder.HasIndex(p => p.JobId)
            .IsUnique()
            .HasFilter("[Status] = 'Accepted'");

        builder.Property(p => p.QuotedLabor).HasPrecision(18, 2);
        builder.Property(p => p.Message).HasMaxLength(1000);
        builder.Property(p => p.Status).HasConversion<string>().HasMaxLength(30);

        builder.HasOne(p => p.Job)
            .WithMany(j => j.Proposals)
            .HasForeignKey(p => p.JobId)
            .OnDelete(DeleteBehavior.Restrict);
    }
}

public sealed class BillableEntityConfiguration : IEntityTypeConfiguration<BillableEntity>
{
    public void Configure(EntityTypeBuilder<BillableEntity> builder)
    {
        builder.HasKey(b => b.Id);
        builder.Property(b => b.EntityType).HasMaxLength(50).IsRequired();
        builder.Property(b => b.CustomerId).HasMaxLength(450).IsRequired();
    }
}

public sealed class ServiceBookingConfiguration : IEntityTypeConfiguration<ServiceBooking>
{
    public void Configure(EntityTypeBuilder<ServiceBooking> builder)
    {
        builder.HasKey(b => b.Id);
        builder.HasIndex(b => b.BillableEntityId).IsUnique();
        builder.HasIndex(b => b.JobId).IsUnique().HasFilter("[JobId] IS NOT NULL");
        builder.HasIndex(b => b.ProposalId).IsUnique().HasFilter("[ProposalId] IS NOT NULL");

        builder.Property(b => b.ServiceLocation).HasColumnType("geography").IsRequired();
        builder.Property(b => b.AddressText).HasMaxLength(300).IsRequired();
        builder.Property(b => b.Status).HasConversion<string>().HasMaxLength(30);
        builder.Property(b => b.CancellationReason).HasMaxLength(500);

        // Money & Rates
        builder.Property(b => b.LaborAmount).HasPrecision(18, 2);
        builder.Property(b => b.UrgencyFee).HasPrecision(18, 2);
        builder.Property(b => b.CommissionRate).HasPrecision(5, 4);
        builder.Property(b => b.PlatformFee).HasPrecision(18, 2);
        builder.Property(b => b.MaterialsAmount).HasPrecision(18, 2);

        // Stored computed column in SQL Server: LaborAmount + UrgencyFee + MaterialsAmount
        builder.Property(b => b.TotalAmount)
            .HasPrecision(18, 2)
            .HasComputedColumnSql("[LaborAmount] + [UrgencyFee] + [MaterialsAmount]", stored: true);

        builder.Property(b => b.RowVersion).IsRowVersion();

        builder.HasOne(b => b.BillableEntity)
            .WithOne()
            .HasForeignKey<ServiceBooking>(b => b.BillableEntityId)
            .OnDelete(DeleteBehavior.Restrict);

        builder.HasIndex(b => new { b.ProfileId, b.Status });
        builder.HasIndex(b => new { b.CustomerId, b.CreatedAtUtc });
    }
}

public sealed class BookingStatusHistoryConfiguration : IEntityTypeConfiguration<BookingStatusHistory>
{
    public void Configure(EntityTypeBuilder<BookingStatusHistory> builder)
    {
        builder.HasKey(h => h.Id);
        builder.Property(h => h.FromStatus).HasConversion<string>().HasMaxLength(30);
        builder.Property(h => h.ToStatus).HasConversion<string>().HasMaxLength(30);
        builder.Property(h => h.Notes).HasMaxLength(500);

        builder.HasOne<ServiceBooking>()
            .WithMany(b => b.StatusHistory)
            .HasForeignKey(h => h.BookingId)
            .OnDelete(DeleteBehavior.Cascade);
    }
}

public sealed class PartForRepairConfiguration : IEntityTypeConfiguration<PartForRepair>
{
    public void Configure(EntityTypeBuilder<PartForRepair> builder)
    {
        builder.HasKey(p => p.Id);
        builder.Property(p => p.ItemDescription).HasMaxLength(200).IsRequired();
        builder.Property(p => p.UnitPrice).HasPrecision(18, 2);
        builder.Property(p => p.LineTotal)
            .HasPrecision(18, 2)
            .HasComputedColumnSql("[Quantity] * [UnitPrice]", stored: true);

        builder.Property(p => p.ApprovalStatus).HasConversion<string>().HasMaxLength(30);

        builder.HasOne<ServiceBooking>()
            .WithMany(b => b.Parts)
            .HasForeignKey(p => p.BookingId)
            .OnDelete(DeleteBehavior.Cascade);
    }
}

public sealed class InvoiceConfiguration : IEntityTypeConfiguration<Invoice>
{
    public void Configure(EntityTypeBuilder<Invoice> builder)
    {
        builder.HasKey(i => i.Id);
        builder.HasIndex(i => i.InvoiceNumber).IsUnique();
        builder.HasIndex(i => i.BillableEntityId).IsUnique();

        builder.Property(i => i.InvoiceNumber).HasMaxLength(30).IsRequired();
        builder.Property(i => i.LaborAmount).HasPrecision(18, 2);
        builder.Property(i => i.UrgencyFee).HasPrecision(18, 2);
        builder.Property(i => i.MaterialsAmount).HasPrecision(18, 2);
        builder.Property(i => i.PlatformFee).HasPrecision(18, 2);
        builder.Property(i => i.TotalPayable).HasPrecision(18, 2);
        builder.Property(i => i.ProviderPayout).HasPrecision(18, 2);
        builder.Property(i => i.PaidStatus).HasConversion<string>().HasMaxLength(30);

        builder.HasOne<BillableEntity>()
            .WithOne(b => b.Invoice)
            .HasForeignKey<Invoice>(i => i.BillableEntityId)
            .OnDelete(DeleteBehavior.Restrict);
    }
}

public sealed class PaymentTransactionConfiguration : IEntityTypeConfiguration<PaymentTransaction>
{
    public void Configure(EntityTypeBuilder<PaymentTransaction> builder)
    {
        builder.HasKey(p => p.Id);
        builder.HasIndex(p => p.IdempotencyKey).IsUnique();

        builder.Property(p => p.Amount).HasPrecision(18, 2);
        builder.Property(p => p.Type).HasConversion<string>().HasMaxLength(30);
        builder.Property(p => p.Method).HasConversion<string>().HasMaxLength(30);
        builder.Property(p => p.Status).HasConversion<string>().HasMaxLength(30);
        builder.Property(p => p.GatewayReference).HasMaxLength(100);
        builder.Property(p => p.IdempotencyKey).HasMaxLength(100).IsRequired();

        builder.HasOne(p => p.BillableEntity)
            .WithMany(b => b.Payments)
            .HasForeignKey(p => p.BillableEntityId)
            .OnDelete(DeleteBehavior.Restrict);
    }
}

public sealed class ReviewConfiguration : IEntityTypeConfiguration<Review>
{
    public void Configure(EntityTypeBuilder<Review> builder)
    {
        builder.HasKey(r => r.Id);
        builder.HasIndex(r => r.BookingId).IsUnique();
        builder.Property(r => r.Comment).HasMaxLength(1000);
    }
}

public sealed class NotificationConfiguration : IEntityTypeConfiguration<Notification>
{
    public void Configure(EntityTypeBuilder<Notification> builder)
    {
        builder.HasKey(n => n.Id);
        builder.Property(n => n.Type).HasConversion<string>().HasMaxLength(50);
        builder.Property(n => n.PayloadJson).IsRequired();

        builder.HasIndex(n => new { n.UserId, n.IsRead, n.CreatedAtUtc });
    }
}
