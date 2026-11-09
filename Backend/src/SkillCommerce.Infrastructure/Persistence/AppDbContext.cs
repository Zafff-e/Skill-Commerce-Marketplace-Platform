using Microsoft.AspNetCore.Identity.EntityFrameworkCore;
using Microsoft.EntityFrameworkCore;
using SkillCommerce.Domain.Billing;
using SkillCommerce.Domain.Bookings;
using SkillCommerce.Domain.Identity;
using SkillCommerce.Domain.Jobs;
using SkillCommerce.Domain.Notifications;
using SkillCommerce.Domain.Providers;
using SkillCommerce.Domain.Reviews;
using SkillCommerce.Domain.Taxonomy;

namespace SkillCommerce.Infrastructure.Persistence;

public class AppDbContext(DbContextOptions<AppDbContext> options)
    : IdentityDbContext<ApplicationUser>(options)
{
    public DbSet<RefreshToken> RefreshTokens => Set<RefreshToken>();
    public DbSet<ProviderProfile> ProviderProfiles => Set<ProviderProfile>();
    public DbSet<ProviderSkill> ProviderSkills => Set<ProviderSkill>();
    public DbSet<VerificationDocument> VerificationDocuments => Set<VerificationDocument>();
    public DbSet<SkillCategory> SkillCategories => Set<SkillCategory>();
    public DbSet<SkillSet> SkillSets => Set<SkillSet>();
    public DbSet<Product> Products => Set<Product>();
    public DbSet<Job> Jobs => Set<Job>();
    public DbSet<Proposal> Proposals => Set<Proposal>();
    public DbSet<BillableEntity> BillableEntities => Set<BillableEntity>();
    public DbSet<ServiceBooking> ServiceBookings => Set<ServiceBooking>();
    public DbSet<BookingStatusHistory> BookingStatusHistory => Set<BookingStatusHistory>();
    public DbSet<PartForRepair> PartsForRepair => Set<PartForRepair>();
    public DbSet<Invoice> Invoices => Set<Invoice>();
    public DbSet<PaymentTransaction> PaymentTransactions => Set<PaymentTransaction>();
    public DbSet<Review> Reviews => Set<Review>();
    public DbSet<Notification> Notifications => Set<Notification>();

    protected override void OnModelCreating(ModelBuilder builder)
    {
        base.OnModelCreating(builder);

        // Apply all configurations in this assembly
        builder.ApplyConfigurationsFromAssembly(typeof(AppDbContext).Assembly);

        // Global conventions:
        // 1. Restrict delete behavior by default (prevents accidental cascade delete of audit ledgers)
        foreach (var relationship in builder.Model.GetEntityTypes().SelectMany(e => e.GetForeignKeys()))
        {
            relationship.DeleteBehavior = DeleteBehavior.Restrict;
        }

        // 2. Cascade delete only for owned child items (ProviderSkills, VerificationDocuments, RefreshTokens)
        builder.Entity<ProviderSkill>()
            .HasOne(ps => ps.Profile)
            .WithMany(p => p.Skills)
            .HasForeignKey(ps => ps.ProfileId)
            .OnDelete(DeleteBehavior.Cascade);

        builder.Entity<VerificationDocument>()
            .HasOne<ProviderProfile>()
            .WithMany(p => p.Documents)
            .HasForeignKey(d => d.ProfileId)
            .OnDelete(DeleteBehavior.Cascade);

        builder.Entity<RefreshToken>()
            .HasOne<ApplicationUser>()
            .WithMany()
            .HasForeignKey(r => r.UserId)
            .OnDelete(DeleteBehavior.Cascade);
    }
}

